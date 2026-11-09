# =============================================================================
# Vertex AI Endpoint and Model Registration Module
# =============================================================================
# Registers containerized models in Vertex AI Model Registry and exposes an
# online prediction endpoint for low-latency inference.
# =============================================================================

locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    module     = "vertex-endpoint"
  })

  # Sanitize endpoint name to valid GCP format (alphanumeric, hyphens, <= 128 chars)
  endpoint_name = lower(replace(var.endpoint_display_name, "[^a-zA-Z0-9-]", "-"))
}

# -----------------------------------------------------------------------------
# Vertex AI Online Prediction Endpoint
# -----------------------------------------------------------------------------
resource "google_vertex_ai_endpoint" "endpoint" {
  name         = local.endpoint_name
  display_name = var.endpoint_display_name
  project      = var.project_id
  region       = var.region
  network      = var.network_id

  labels = local.common_labels

  description = "Managed prediction endpoint created by MLOps-in-a-Box"
}

# -----------------------------------------------------------------------------
# Vertex AI Model Registry Resource
# -----------------------------------------------------------------------------
# Registers the containerized model metadata in Vertex AI. Traffic splitting
# and deployment onto the endpoint is performed dynamically via CI/CD pipelines
# to allow progressive rollouts and zero-downtime rollbacks.
# -----------------------------------------------------------------------------
resource "google_vertex_ai_model" "model" {
  display_name = var.model_display_name
  description  = var.model_description
  project      = var.project_id
  region       = var.region

  artifact_uri = var.artifact_uri != "" ? var.artifact_uri : null

  container_spec {
    image_uri     = var.container_image_uri
    predict_route = var.predict_route
    health_route  = var.health_route
  }

  labels = local.common_labels
}

