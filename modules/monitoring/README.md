# Monitoring & Operational Guardrails Module

Terraform module to configure comprehensive observability and proactive cost guardrails for machine learning models hosted on Google Cloud Vertex AI.

## Features

1. **Model Observability Dashboard:**
   - Real-time online prediction request volume & request rate
   - p50, p95, and p99 inference latencies
   - Prediction failure & error rates (4xx / 5xx)
   - CPU and memory utilization on endpoint worker nodes

2. **Proactive Alert Policies:**
   - **High Latency Alert:** Triggers when p99 prediction latency exceeds threshold (default: 1000ms for 5 consecutive minutes).
   - **High Error Rate Alert:** Triggers when error rate exceeds threshold (default: 5% for 3 minutes).
   - Automated email notifications dispatched via Cloud Monitoring channels.

3. **Statistical Data Drift Detection:**
   - Cloud Function (Gen 2) triggered on a schedule (default: every 6 hours).
   - Evaluates incoming inference feature distributions against baseline dataset statistics.
   - Computes standardized Z-scores and emits actionable warnings if drift is identified.

4. **Idle Resource Auto-Shutdown (Cost Guardrail):**
   - Cloud Function + Cloud Scheduler job executing every hour.
   - Monitors Vertex AI endpoint traffic; if zero inference requests have been processed over the designated idle window (default: 2 hours), it automatically undeploys idle models to stop compute charges.

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project_id           = "my-gcp-project"
  region               = "us-central1"
  endpoint_id          = "123456789012345678"
  alert_email          = "mlops-alerts@myorg.com"
  latency_threshold_ms = 800
  error_rate_threshold = 0.05
  enable_drift_check   = true
  enable_auto_shutdown = true
  idle_timeout_hours   = 2

  labels = {
    environment = "prod"
    system      = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP Project ID | `string` | n/a | yes |
| `region` | GCP Region | `string` | `"us-central1"` | no |
| `name_prefix` | Resource naming prefix | `string` | `"mlops"` | no |
| `endpoint_id` | Vertex AI Endpoint ID | `string` | `""` | no |
| `alert_email` | Alert notification email | `string` | n/a | yes |
| `latency_threshold_ms` | Max tolerable p99 latency in ms | `number` | `1000` | no |
| `error_rate_threshold` | Max tolerable error rate fraction | `number` | `0.05` | no |
| `enable_drift_check` | Deploy drift detection function | `bool` | `true` | no |
| `enable_auto_shutdown` | Deploy idle auto-shutdown function | `bool` | `true` | no |
| `idle_timeout_hours` | Hours of inactivity before shutdown | `number` | `2` | no |
| `labels` | Labels to attach to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `notification_channel_id` | ID of the notification channel |
| `dashboard_id` | ID of the Cloud Monitoring dashboard |
| `high_latency_alert_id` | ID of the latency alert policy |
| `error_rate_alert_id` | ID of the error rate alert policy |
| `drift_check_function_url` | Invocation URL for drift check function |
| `auto_shutdown_function_url` | Invocation URL for auto-shutdown function |
