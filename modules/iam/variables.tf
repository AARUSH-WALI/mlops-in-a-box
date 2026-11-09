variable "project_id" {
  description = "GCP project ID where IAM resources will be created."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names (service accounts, WIF pool, etc.)."
  type        = string
  default     = "mlops"
}

variable "github_org" {
  description = "GitHub organization or username that owns the repository."
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name (without the org/owner prefix)."
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources that support them."
  type        = map(string)
  default     = {}
}
