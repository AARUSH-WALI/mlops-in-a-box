output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}

output "region" {
  description = "The configured GCP region."
  value       = var.region
}

output "enabled_apis" {
  description = "List of enabled API services."
  value       = [for api in google_project_service.apis : api.service]
}

output "state_bucket_name" {
  description = "Name of the Terraform state bucket."
  value       = google_storage_bucket.tfstate.name
}

output "state_bucket_url" {
  description = "GCS URL of the Terraform state bucket."
  value       = "gs://${google_storage_bucket.tfstate.name}"
}
