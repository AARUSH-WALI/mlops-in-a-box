# -----------------------------------------------------------------------------
# Outputs — Vertex AI Endpoint Module
# -----------------------------------------------------------------------------

output "endpoint_id" {
  description = "The ID of the created Vertex AI Endpoint."
  value       = google_vertex_ai_endpoint.endpoint.id
}

output "endpoint_name" {
  description = "The resource name of the created Vertex AI Endpoint."
  value       = google_vertex_ai_endpoint.endpoint.name
}

output "endpoint_network" {
  description = "The VPC network attached to the endpoint, if configured."
  value       = google_vertex_ai_endpoint.endpoint.network
}
