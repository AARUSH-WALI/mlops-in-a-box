# Budget Module

Creates a GCP billing budget with email alert notifications to prevent surprise costs. The module sets up a monthly budget scoped to a single project and configures three threshold-based alert rules (50% actual, 80% actual, 100% forecasted).

## Usage

```hcl
module "budget" {
  source = "./modules/budget"

  project_id      = "my-gcp-project"
  billing_account = "01ABCD-234EFG-567HIJ"
  alert_email     = "team@example.com"

  name_prefix         = "mlops"
  monthly_budget_usd  = 100

  labels = {
    environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP project ID to scope the budget. | `string` | — | yes |
| `billing_account` | GCP billing account ID (e.g. `01ABCD-234EFG-567HIJ`). | `string` | — | yes |
| `alert_email` | Email address that receives budget alert notifications. | `string` | — | yes |
| `name_prefix` | Prefix for resource names. | `string` | `"mlops"` | no |
| `monthly_budget_usd` | Monthly budget amount in USD. | `number` | `100` | no |
| `labels` | Labels to apply to resources that support them. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `budget_id` | The billing budget ID. |
| `budget_name` | The budget display name. |
| `notification_channel_name` | The notification channel resource name. |

## Alert Thresholds

| Threshold | Spend Basis | Description |
|-----------|-------------|-------------|
| 50% | Current spend | Alert when actual spend reaches half the budget |
| 80% | Current spend | Alert when actual spend reaches 80% of the budget |
| 100% | Forecasted spend | Alert when forecasted spend is projected to hit the budget |

## Resources Created

- `google_monitoring_notification_channel.email` — Email notification channel
- `google_billing_budget.monthly` — Monthly billing budget with threshold alerts
