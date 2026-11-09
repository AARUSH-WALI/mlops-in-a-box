# Test registry module planning

variables {
  project_id    = "test-mlops-project-12345"
  region        = "us-central1"
  repository_id = "test-containers"
}

run "plan_registry" {
  command = plan

  module {
    source = "./modules/registry"
  }

  assert {
    condition     = output.repository_id == "test-containers"
    error_message = "Repository ID did not match input variable"
  }

  assert {
    condition     = output.registry_url == "us-central1-docker.pkg.dev/test-mlops-project-12345/test-containers"
    error_message = "Docker registry URL constructed incorrectly"
  }
}
