# -----------------------------------------------------------------------------
# Outputs — Monitoring & Operational Guardrails Module
# -----------------------------------------------------------------------------

output "notification_channel_id" {
  description = "The ID of the monitoring notification channel."
  value       = google_monitoring_notification_channel.email.id
}

output "dashboard_id" {
  description = "The ID of the Cloud Monitoring operational dashboard."
  value       = google_monitoring_dashboard.mlops_dashboard.id
}

output "high_latency_alert_id" {
  description = "The resource ID of the high inference latency alert policy."
  value       = google_monitoring_alert_policy.high_latency.id
}

output "error_rate_alert_id" {
  description = "The resource ID of the error rate alert policy."
  value       = google_monitoring_alert_policy.error_rate.id
}

output "drift_check_function_url" {
  description = "The HTTP invocation URL of the drift detection Cloud Function, if enabled."
  value       = var.enable_drift_check && length(google_cloudfunctions2_function.drift_check) > 0 ? google_cloudfunctions2_function.drift_check[0].url : null
}

output "auto_shutdown_function_url" {
  description = "The HTTP invocation URL of the auto-shutdown Cloud Function, if enabled."
  value       = var.enable_auto_shutdown && length(google_cloudfunctions2_function.auto_shutdown) > 0 ? google_cloudfunctions2_function.auto_shutdown[0].url : null
}
