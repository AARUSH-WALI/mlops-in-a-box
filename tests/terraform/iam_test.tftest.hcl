# Test IAM module planning and WIF configuration

variables {
  project_id  = "test-mlops-project-12345"
  name_prefix = "test-mlops"
  github_org  = "test-org"
  github_repo = "test-repo"
}

run "plan_iam" {
  command = plan

  module {
    source = "./modules/iam"
  }

  assert {
    condition     = length(output.vertex_sa_email) > 0
    error_message = "Vertex AI SA email output must not be empty"
  }

  assert {
    condition     = length(output.cicd_sa_email) > 0
    error_message = "CI/CD SA email output must not be empty"
  }

  assert {
    condition     = length(output.wif_provider_name) > 0
    error_message = "WIF provider name must not be empty"
  }
}

