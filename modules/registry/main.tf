# Artifact Registry — Docker repository for ML container images

resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  format        = "DOCKER"
  description   = "Container images for ML model training and serving"
  labels        = var.labels

  # Automatically purge untagged images after a configurable retention period
  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"

    condition {
      tag_state  = "UNTAGGED"
      older_than = "${var.cleanup_days}d"
    }
  }
}
