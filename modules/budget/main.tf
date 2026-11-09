# --------------------------------------------------------------------------
# Budget Module — Billing budget alerts to prevent surprise costs
# --------------------------------------------------------------------------

# Email notification channel for budget alerts
resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "MLOps Budget Alert"
  type         = "email"

  labels = {
    email_address = var.alert_email
  }
}

# Monthly billing budget with threshold-based alerts
resource "google_billing_budget" "monthly" {
  billing_account = var.billing_account
  display_name    = "${var.name_prefix}-monthly-budget"

  # Scope the budget to a single project
  budget_filter {
    projects = ["projects/${var.project_id}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.monthly_budget_usd)
    }
  }

  # Alert at 50% of actual spend
  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  # Alert at 80% of actual spend
  threshold_rules {
    threshold_percent = 0.8
    spend_basis       = "CURRENT_SPEND"
  }

  # Alert at 100% of forecasted spend
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email.name,
    ]
    disable_default_iam_recipients = false
  }
}
