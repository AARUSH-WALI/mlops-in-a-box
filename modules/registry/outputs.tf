output "repository_id" {
  description = "The Artifact Registry repository ID."
  value       = google_artifact_registry_repository.docker.repository_id
}

output "repository_name" {
  description = "The full resource name of the Artifact Registry repository."
  value       = google_artifact_registry_repository.docker.name
}

output "registry_url" {
  description = "Docker registry URL (e.g., us-central1-docker.pkg.dev/project/repo)."
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}
