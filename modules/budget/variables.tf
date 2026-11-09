# --------------------------------------------------------------------------
# Budget Module — Input Variables
# --------------------------------------------------------------------------

variable "project_id" {
  description = "GCP project ID to scope the budget."
  type        = string
}

variable "billing_account" {
  description = "GCP billing account ID (e.g. 01ABCD-234EFG-567HIJ)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names."
  type        = string
  default     = "mlops"
}

variable "monthly_budget_usd" {
  description = "Monthly budget amount in USD."
  type        = number
  default     = 100
}

variable "alert_email" {
  description = "Email address that receives budget alert notifications."
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources that support them."
  type        = map(string)
  default     = {}
}
