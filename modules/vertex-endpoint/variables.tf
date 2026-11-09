# -----------------------------------------------------------------------------
# Variables — Vertex AI Endpoint Module
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where Vertex AI resources will be deployed."
  type        = string
}

variable "region" {
  description = "The GCP region for Vertex AI resources (e.g., us-central1)."
  type        = string
  default     = "us-central1"
}

variable "endpoint_display_name" {
  description = "Display name for the Vertex AI prediction endpoint."
  type        = string
  default     = "mlops-prediction-endpoint"
}

variable "network_id" {
  description = "Optional full resource name of the VPC network for private endpoint deployment."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to attach to the endpoint."
  type        = map(string)
  default     = {}
}
