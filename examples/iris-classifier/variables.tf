# -----------------------------------------------------------------------------
# Variables — Iris Classifier End-to-End Example Root Module
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID to deploy all resources into."
  type        = string
}

variable "region" {
  description = "The GCP region for all regional resources (compute, buckets, Vertex AI)."
  type        = string
  default     = "us-central1"
}

variable "name_prefix" {
  description = "Resource naming prefix to keep resources distinct and identifiable."
  type        = string
  default     = "iris-mlbox"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "github_org" {
  description = "GitHub organization or account name for Workload Identity Federation."
  type        = string
  default     = "aarushwali"
}

variable "github_repo" {
  description = "GitHub repository name for Workload Identity Federation."
  type        = string
  default     = "mlops-in-a-box"
}

variable "container_image_tag" {
  description = "Tag of the serving container image to register with Vertex AI."
  type        = string
  default     = "latest"
}

variable "enable_budget" {
  description = "Whether to provision the billing budget alert module (requires billing account ID)."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "GCP Billing Account ID (e.g., 012345-6789AB-CDEF01). Required if enable_budget is true."
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Email address for budget and monitoring alert notifications."
  type        = string
  default     = "alerts@example.com"
}

variable "monthly_budget_usd" {
  description = "Monthly budget limit in USD."
  type        = number
  default     = 100
}

variable "labels" {
  description = "Labels to attach to all provisioned resources."
  type        = map(string)
  default = {
    project = "mlops-in-a-box"
    example = "iris-classifier"
  }
}
