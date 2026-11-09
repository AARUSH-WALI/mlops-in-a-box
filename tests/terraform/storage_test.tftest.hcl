# Test storage module planning

variables {
  project_id  = "test-mlops-project-12345"
  region      = "us-central1"
  name_prefix = "test-mlops"
  environment = "dev"
}

run "plan_storage" {
  command = plan

  module {
    source = "./modules/storage"
  }

  assert {
    condition     = output.data_bucket_name == "test-mlops-project-12345-test-mlops-data-dev"
    error_message = "Data bucket name did not match expected pattern"
  }

  assert {
    condition     = output.models_bucket_name == "test-mlops-project-12345-test-mlops-models-dev"
    error_message = "Models bucket name did not match expected pattern"
  }

  assert {
    condition     = output.staging_bucket_name == "test-mlops-project-12345-test-mlops-staging-dev"
    error_message = "Staging bucket name did not match expected pattern"
  }
}
