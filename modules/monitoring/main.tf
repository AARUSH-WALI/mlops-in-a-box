# =============================================================================
# Monitoring, Dashboards, and Operational Guardrails Module
# =============================================================================
# Provisions:
# 1. Cloud Monitoring Notification Channels (Email)
# 2. Operational Dashboards (Latency, Request Counts, Error Rates)
# 3. Alert Policies for SLA Violations (p99 latency, 5xx errors)
# 4. Cloud Functions + Cloud Scheduler for Drift Detection & Auto-Shutdown
# =============================================================================

locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "monitoring"
  })
}

# -----------------------------------------------------------------------------
# 1. Notification Channel (Email)
# -----------------------------------------------------------------------------
resource "google_monitoring_notification_channel" "email" {
  display_name = "${var.name_prefix}-monitoring-alerts"
  type         = "email"
  project      = var.project_id

  labels = {
    email_address = var.alert_email
  }

  user_labels = local.common_labels
}

# -----------------------------------------------------------------------------
# 2. Operational Dashboard (Latency, Request Rate, Errors)
# -----------------------------------------------------------------------------
resource "google_monitoring_dashboard" "mlops_dashboard" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "${var.name_prefix}-model-observability"
    gridLayout = {
      columns = "2"
      widgets = [
        {
          title = "Online Prediction Request Volume"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"aiplatform.googleapis.com/prediction/online/prediction_count\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        },
        {
          title = "Online Prediction Latency (p50 / p95 / p99)"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"aiplatform.googleapis.com/prediction/online/latencies\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
                  aggregation = {
                    alignmentPeriod    = "60s"
                    perSeriesAligner   = "ALIGN_PERCENTILE_99"
                    crossSeriesReducer = "REDUCE_PERCENTILE_99"
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        },
        {
          title = "Prediction Error Count (5xx / 4xx)"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"aiplatform.googleapis.com/prediction/online/error_count\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_RATE"
                  }
                }
              }
              plotType = "BAR"
            }]
          }
        },
        {
          title = "Endpoint CPU & Memory Utilization"
          xyChart = {
            dataSets = [{
              timeSeriesQuery = {
                timeSeriesFilter = {
                  filter = "metric.type=\"kubernetes.io/container/cpu/utilization\" resource.type=\"k8s_container\""
                  aggregation = {
                    alignmentPeriod  = "60s"
                    perSeriesAligner = "ALIGN_MEAN"
                  }
                }
              }
              plotType = "LINE"
            }]
          }
        }
      ]
    }
  })
}

# -----------------------------------------------------------------------------
# 3. Alert Policies
# -----------------------------------------------------------------------------
# Alert when 99th percentile inference latency exceeds threshold
resource "google_monitoring_alert_policy" "high_latency" {
  display_name = "${var.name_prefix}-high-inference-latency"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "p99 Prediction Latency > ${var.latency_threshold_ms}ms"

    condition_threshold {
      filter          = "metric.type=\"aiplatform.googleapis.com/prediction/online/latencies\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
      duration        = "300s" # 5 consecutive minutes
      comparison      = "COMPARISON_GT"
      threshold_value = var.latency_threshold_ms

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_99"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "Vertex AI Endpoint latency has breached the p99 threshold of ${var.latency_threshold_ms}ms. Inspect autoscaling limits and compute resource sizing."
    mime_type = "text/markdown"
  }

  user_labels = local.common_labels
}

# Alert when prediction error rate exceeds threshold
resource "google_monitoring_alert_policy" "error_rate" {
  display_name = "${var.name_prefix}-high-error-rate"
  project      = var.project_id
  combiner     = "OR"

  conditions {
    display_name = "Prediction Error Rate > ${var.error_rate_threshold * 100}%"

    condition_threshold {
      filter          = "metric.type=\"aiplatform.googleapis.com/prediction/online/error_count\" resource.type=\"aiplatform.googleapis.com/Endpoint\""
      duration        = "180s" # 3 minutes
      comparison      = "COMPARISON_GT"
      threshold_value = var.error_rate_threshold

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]

  documentation {
    content   = "Vertex AI Endpoint has experienced elevated prediction failure rates. Check container health checks and application logs in Cloud Logging."
    mime_type = "text/markdown"
  }

  user_labels = local.common_labels
}

# -----------------------------------------------------------------------------
# 4. Storage for Cloud Function Source Archives
# -----------------------------------------------------------------------------
resource "google_storage_bucket" "function_source" {
  count                       = (var.enable_drift_check || var.enable_auto_shutdown) ? 1 : 0
  name                        = "${var.project_id}-${var.name_prefix}-monitoring-funcs"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 14 # Clean older source builds
    }
  }

  labels = local.common_labels
}

# Zip drift detection function
data "archive_file" "drift_check_zip" {
  count       = var.enable_drift_check ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/functions/drift_check"
  output_path = "${path.module}/drift_check.zip"
}

resource "google_storage_bucket_object" "drift_check_archive" {
  count  = var.enable_drift_check ? 1 : 0
  name   = "drift-check-${data.archive_file.drift_check_zip[0].output_md5}.zip"
  bucket = google_storage_bucket.function_source[0].name
  source = data.archive_file.drift_check_zip[0].output_path
}

# Drift detection Cloud Function (Gen 2)
resource "google_cloudfunctions2_function" "drift_check" {
  count       = var.enable_drift_check ? 1 : 0
  name        = "${var.name_prefix}-drift-check"
  location    = var.region
  project     = var.project_id
  description = "Periodic model prediction feature drift checker"

  build_config {
    runtime     = "python311"
    entry_point = "check_drift"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source[0].name
        object = google_storage_bucket_object.drift_check_archive[0].name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 120
    environment_variables = {
      GCP_PROJECT        = var.project_id
      DRIFT_Z_THRESHOLD  = "2.5"
      VERTEX_ENDPOINT_ID = var.endpoint_id
    }
  }

  labels = local.common_labels
}

# Scheduler job for Drift Check (Runs every 6 hours)
resource "google_cloud_scheduler_job" "drift_check_schedule" {
  count       = var.enable_drift_check ? 1 : 0
  name        = "${var.name_prefix}-drift-check-schedule"
  project     = var.project_id
  region      = var.region
  description = "Hourly/6-hourly execution of drift detection check"
  schedule    = "0 */6 * * *"
  time_zone   = "UTC"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions2_function.drift_check[0].url

    oidc_token {
      service_account_email = "${var.project_id}@appspot.gserviceaccount.com"
    }
  }
}

# Zip auto-shutdown function
data "archive_file" "auto_shutdown_zip" {
  count       = var.enable_auto_shutdown ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/functions/auto_shutdown"
  output_path = "${path.module}/auto_shutdown.zip"
}

resource "google_storage_bucket_object" "auto_shutdown_archive" {
  count  = var.enable_auto_shutdown ? 1 : 0
  name   = "auto-shutdown-${data.archive_file.auto_shutdown_zip[0].output_md5}.zip"
  bucket = google_storage_bucket.function_source[0].name
  source = data.archive_file.auto_shutdown_zip[0].output_path
}

# Auto-shutdown Cloud Function (Gen 2)
resource "google_cloudfunctions2_function" "auto_shutdown" {
  count       = var.enable_auto_shutdown ? 1 : 0
  name        = "${var.name_prefix}-auto-shutdown"
  location    = var.region
  project     = var.project_id
  description = "Idle resource guardrail that automatically undeploys unused endpoints"

  build_config {
    runtime     = "python311"
    entry_point = "auto_shutdown_check"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source[0].name
        object = google_storage_bucket_object.auto_shutdown_archive[0].name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 120
    environment_variables = {
      GCP_PROJECT        = var.project_id
      GCP_REGION         = var.region
      VERTEX_ENDPOINT_ID = var.endpoint_id
      IDLE_TIMEOUT_HOURS = tostring(var.idle_timeout_hours)
    }
  }

  labels = local.common_labels
}

# Scheduler job for Auto-Shutdown (Runs every hour)
resource "google_cloud_scheduler_job" "auto_shutdown_schedule" {
  count       = var.enable_auto_shutdown ? 1 : 0
  name        = "${var.name_prefix}-auto-shutdown-schedule"
  project     = var.project_id
  region      = var.region
  description = "Hourly check for idle Vertex AI endpoints to avoid unwanted billing charges"
  schedule    = "0 * * * *"
  time_zone   = "UTC"

  http_target {
    http_method = "GET"
    uri         = google_cloudfunctions2_function.auto_shutdown[0].url

    oidc_token {
      service_account_email = "${var.project_id}@appspot.gserviceaccount.com"
    }
  }
}

