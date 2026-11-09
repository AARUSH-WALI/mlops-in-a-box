# Test Vertex AI endpoint module planning

variables {
  project_id            = "test-mlops-project-12345"
  region                = "us-central1"
  endpoint_display_name = "test-iris-endpoint"
  model_display_name    = "test-iris-model"
  container_image_uri   = "us-central1-docker.pkg.dev/test-mlops-project-12345/mlops-containers/iris-classifier:latest"
}

run "plan_vertex_endpoint" {
  command = plan

  module {
    source = "./modules/vertex-endpoint"
  }

  assert {
    condition     = output.endpoint_name == "test-iris-endpoint"
    error_message = "Endpoint name must match sanitized display name"
  }

  assert {
    condition     = output.endpoint_network == null
    error_message = "Endpoint network should default to null for public endpoint"
  }
}

