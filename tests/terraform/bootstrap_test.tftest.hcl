# Test bootstrap module planning and validation

variables {
  project_id = "test-mlops-project-12345"
  region     = "us-central1"
  labels = {
    environment = "test"
  }
}

run "plan_bootstrap" {
  command = plan

  module {
    source = "./modules/bootstrap"
  }

  assert {
    condition     = output.project_id == "test-mlops-project-12345"
    error_message = "Project ID output did not match input variable"
  }

  assert {
    condition     = output.state_bucket_name == "test-mlops-project-12345-tfstate"
    error_message = "State bucket name does not conform to expected pattern"
  }

  assert {
    condition     = length(output.enabled_apis) >= 10
    error_message = "Expected at least 10 critical GCP APIs to be enabled"
  }
}
