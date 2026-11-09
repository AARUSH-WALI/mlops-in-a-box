output "vertex_sa_email" {
  description = "Email address of the Vertex AI service account."
  value       = google_service_account.vertex_ai.email
}

output "vertex_sa_name" {
  description = "Fully-qualified resource name of the Vertex AI service account."
  value       = google_service_account.vertex_ai.name
}

output "cicd_sa_email" {
  description = "Email address of the CI/CD service account."
  value       = google_service_account.cicd.email
}

output "cicd_sa_name" {
  description = "Fully-qualified resource name of the CI/CD service account."
  value       = google_service_account.cicd.name
}

output "wif_pool_name" {
  description = "Fully-qualified resource name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.github.name
}

output "wif_provider_name" {
  description = "Fully-qualified resource name of the Workload Identity Provider (used in GitHub Actions auth config)."
  value       = google_iam_workload_identity_pool_provider.github.name
}
