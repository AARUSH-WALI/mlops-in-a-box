# =============================================================================
# Input Variables — Storage Module
# =============================================================================

variable "project_id" {
  description = "GCP project ID where the storage buckets will be created."
  type        = string
}

variable "region" {
  description = "GCP region for bucket location (e.g., us-central1)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for bucket names, used to namespace resources (e.g., mlops)."
  type        = string
  default     = "mlops"
}

variable "environment" {
  description = "Environment name used in bucket naming and labels (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "force_destroy" {
  description = "Allow Terraform to destroy the data and models buckets even if they contain objects. Does not affect the staging bucket, which is always force-destroyable."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of key/value labels to apply to all buckets."
  type        = map(string)
  default     = {}
}
