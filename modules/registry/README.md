# Artifact Registry Module

Creates a Google Artifact Registry repository configured for Docker container images, suitable for storing ML model training and serving images.

The module includes an automatic cleanup policy that deletes untagged images after a configurable retention period, helping to control storage costs.

## Usage

```hcl
module "registry" {
  source = "./modules/registry"

  project_id    = "my-gcp-project"
  region        = "us-central1"
  repository_id = "mlops-containers"
  cleanup_days  = 30

  labels = {
    environment = "production"
    team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP project ID where the Artifact Registry repository will be created. | `string` | — | yes |
| `region` | GCP region for the Artifact Registry repository. | `string` | — | yes |
| `repository_id` | The ID of the Artifact Registry repository. | `string` | `"mlops-containers"` | no |
| `cleanup_days` | Number of days after which untagged images are automatically deleted. | `number` | `30` | no |
| `labels` | A map of labels to apply to the Artifact Registry repository. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `repository_id` | The Artifact Registry repository ID. |
| `repository_name` | The full resource name of the Artifact Registry repository. |
| `registry_url` | Docker registry URL (e.g., `us-central1-docker.pkg.dev/project/repo`). |
