# Bootstrap Module

Enables required GCP project APIs and creates a versioned Cloud Storage bucket for Terraform remote state.

## Usage

```hcl
module "bootstrap" {
  source = "./modules/bootstrap"

  project_id = "my-gcp-project"
  region     = "us-central1"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

After applying, configure your backend:

```hcl
terraform {
  backend "gcs" {
    bucket = "my-gcp-project-tfstate"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | The GCP project ID where APIs will be enabled and the state bucket created. | `string` | — | yes |
| `region` | GCP region for the Terraform state bucket. | `string` | `"us-central1"` | no |
| `labels` | Labels to apply to resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | The GCP project ID. |
| `region` | The configured GCP region. |
| `enabled_apis` | List of enabled API services. |
| `state_bucket_name` | Name of the Terraform state bucket. |
| `state_bucket_url` | GCS URL of the Terraform state bucket. |

## Notes

- **`disable_on_destroy = false`** — Destroying the `google_project_service` resources will *not* disable the APIs, preventing breakage of other project resources.
- **`prevent_destroy`** — The state bucket has a `prevent_destroy` lifecycle rule to guard against accidental deletion.
- **Versioning** — Bucket versioning is enabled so previous state files can be recovered. A lifecycle rule deletes noncurrent versions after 30 days.
