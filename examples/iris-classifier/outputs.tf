# -----------------------------------------------------------------------------
# Outputs — Iris Classifier End-to-End Example
# -----------------------------------------------------------------------------

output "project_id" {
  description = "The GCP project ID."
  value       = var.project_id
}

output "region" {
  description = "The GCP region."
  value       = var.region
}

output "state_bucket_name" {
  description = "Name of the GCS bucket for remote Terraform state."
  value       = module.bootstrap.state_bucket_name
}

output "registry_url" {
  description = "Artifact Registry Docker repository URL for pushing serving/training containers."
  value       = module.registry.registry_url
}

output "data_bucket_name" {
  description = "GCS bucket for training data."
  value       = module.storage.data_bucket_name
}

output "models_bucket_name" {
  description = "GCS bucket for trained model artifacts."
  value       = module.storage.models_bucket_name
}

output "vertex_endpoint_id" {
  description = "The ID of the Vertex AI Prediction Endpoint."
  value       = module.vertex_endpoint.endpoint_id
}

output "vertex_endpoint_name" {
  description = "The resource name of the Vertex AI Prediction Endpoint."
  value       = module.vertex_endpoint.endpoint_name
}

output "wif_provider_name" {
  description = "Full resource name of the Workload Identity Provider for GitHub Actions."
  value       = module.iam.wif_provider_name
}

output "cicd_service_account" {
  description = "Email of the CI/CD Service Account used by GitHub Actions."
  value       = module.iam.cicd_sa_email
}

