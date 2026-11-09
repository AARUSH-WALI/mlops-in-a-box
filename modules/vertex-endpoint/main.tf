# =============================================================================
# Vertex AI Endpoint Module
# =============================================================================
# Provisions a Google Cloud Vertex AI Online Prediction Endpoint.
# Models are uploaded to Vertex AI Model Registry and deployed to this
# endpoint dynamically via CI/CD workflows (deploy.yml) or 'mlbox deploy'.
# =============================================================================

locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "vertex-endpoint"
  })

  # Endpoint resource name must start with a letter and contain only lowercase letters, numbers, and hyphens
  endpoint_name = lower(replace(var.endpoint_display_name, "[^a-zA-Z0-9-]", "-"))
}

# -----------------------------------------------------------------------------
# Vertex AI Online Prediction Endpoint
# -----------------------------------------------------------------------------
resource "google_vertex_ai_endpoint" "endpoint" {
  name         = local.endpoint_name
  display_name = var.endpoint_display_name
  project      = var.project_id
  location     = var.region
  network      = var.network_id

  labels = local.common_labels

  description = "Managed prediction endpoint created by MLOps-in-a-Box"
}
