# -----------------------------------------------------------------------------
# Variables — Monitoring & Operational Guardrails Module
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID to configure monitoring in."
  type        = string
}

variable "region" {
  description = "The GCP region for regional monitoring resources & Cloud Functions."
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Naming prefix for dashboards, alert policies, and scheduler jobs."
  type        = string
  default     = "mlops"
}

variable "endpoint_id" {
  description = "Optional Vertex AI Endpoint ID to filter dashboards and auto-shutdown checks."
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Email address for monitoring alert notifications."
  type        = string
}

variable "latency_threshold_ms" {
  description = "Latency threshold in milliseconds for high latency alert (default: 1000ms)."
  type        = number
  default     = 1000
}

variable "error_rate_threshold" {
  description = "Fraction of failed requests before triggering alert (e.g., 0.05 for 5%)."
  type        = number
  default     = 0.05
}

variable "enable_drift_check" {
  description = "Whether to deploy the automated drift detection Cloud Function & Cloud Scheduler job."
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Whether to deploy the idle resource auto-shutdown Cloud Function & Cloud Scheduler job."
  type        = bool
  default     = true
}

variable "idle_timeout_hours" {
  description = "Hours of inactivity before auto-shutdown undeploys idle models."
  type        = number
  default     = 2
}

variable "labels" {
  description = "Labels to attach to monitoring resources."
  type        = map(string)
  default     = {}
}
