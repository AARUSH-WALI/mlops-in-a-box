# Storage Module

Creates three GCS buckets for an ML pipeline: a **data** bucket for training datasets, a **models** bucket for trained model artifacts, and a **staging** bucket for temporary processing files.

Each bucket is configured with purpose-specific versioning, lifecycle rules, and access controls to balance durability, cost, and operational convenience.

## Usage

```hcl
module "storage" {
  source = "./modules/storage"

  project_id  = "my-gcp-project"
  region      = "us-central1"
  name_prefix = "mlops"
  environment = "prod"

  force_destroy = false

  labels = {
    team = "ml-platform"
  }
}
```

## Bucket Details

| Bucket | Versioning | Lifecycle | Force Destroy |
|--------|-----------|-----------|---------------|
| **Data** — training datasets | ✅ Enabled | — | Configurable (`var.force_destroy`) |
| **Models** — model artifacts | ✅ Enabled | Move to NEARLINE after 90 days | Configurable (`var.force_destroy`) |
| **Staging** — temp files | ❌ Disabled | Delete after 7 days | Always `true` |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID where the storage buckets will be created. | `string` | — | ✅ |
| `region` | GCP region for bucket location (e.g., `us-central1`). | `string` | — | ✅ |
| `name_prefix` | Prefix for bucket names, used to namespace resources. | `string` | `"mlops"` | no |
| `environment` | Environment name used in bucket naming and labels. | `string` | `"dev"` | no |
| `force_destroy` | Allow destroying the data and models buckets even if they contain objects. Does not affect the staging bucket. | `bool` | `false` | no |
| `labels` | A map of key/value labels to apply to all buckets. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `data_bucket_name` | Name of the GCS bucket for training datasets. |
| `data_bucket_url` | GCS URL of the data bucket (`gs://...`). |
| `models_bucket_name` | Name of the GCS bucket for trained model artifacts. |
| `models_bucket_url` | GCS URL of the models bucket (`gs://...`). |
| `staging_bucket_name` | Name of the GCS bucket for temporary processing files. |
| `staging_bucket_url` | GCS URL of the staging bucket (`gs://...`). |
