# --------------------------------------------------------------------------
# Budget Module — Outputs
# --------------------------------------------------------------------------

output "budget_id" {
  description = "The billing budget ID."
  value       = google_billing_budget.monthly.id
}

output "budget_name" {
  description = "The budget display name."
  value       = google_billing_budget.monthly.display_name
}

output "notification_channel_name" {
  description = "The notification channel resource name."
  value       = google_monitoring_notification_channel.email.name
}
