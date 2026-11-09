# Test monitoring module planning

variables {
  project_id           = "test-mlops-project-12345"
  region               = "us-central1"
  alert_email          = "alerts@example.com"
  name_prefix          = "test-mlops"
  enable_drift_check   = false
  enable_auto_shutdown = false
}

run "plan_monitoring" {
  command = plan

  module {
    source = "./modules/monitoring"
  }

  assert {
    condition     = output.notification_channel_id != null
    error_message = "Notification channel ID must be present in plan"
  }

  assert {
    condition     = output.dashboard_id != null
    error_message = "Operational dashboard ID must be present in plan"
  }
}
