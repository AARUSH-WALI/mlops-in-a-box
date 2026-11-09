variable "project_id" {
  description = "The GCP project ID where APIs will be enabled and the state bucket created."
  type        = string
}

variable "region" {
  description = "GCP region for the Terraform state bucket."
  type        = string
  default     = "us-central1"
}

variable "labels" {
  description = "Labels to apply to resources created by this module."
  type        = map(string)
  default     = {}
}
