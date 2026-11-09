# Test budget module planning

variables {
  project_id         = "test-mlops-project-12345"
  billing_account    = "012345-6789AB-CDEF01"
  alert_email        = "alerts@example.com"
  monthly_budget_usd = 100
  name_prefix        = "test-mlops"
}

run "plan_budget" {
  command = plan

  module {
    source = "./modules/budget"
  }

  assert {
    condition     = output.budget_name == "test-mlops-monthly-budget"
    error_message = "Budget display name does not match expected name_prefix pattern"
  }
}

