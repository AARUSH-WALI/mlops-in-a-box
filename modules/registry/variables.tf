variable "project_id" {
  description = "GCP project ID where the Artifact Registry repository will be created."
  type        = string
}

variable "region" {
  description = "GCP region for the Artifact Registry repository."
  type        = string
}

variable "repository_id" {
  description = "The ID of the Artifact Registry repository."
  type        = string
  default     = "mlops-containers"
}

variable "cleanup_days" {
  description = "Number of days after which untagged images are automatically deleted."
  type        = number
  default     = 30
}

variable "labels" {
  description = "A map of labels to apply to the Artifact Registry repository."
  type        = map(string)
  default     = {}
}
