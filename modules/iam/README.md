# IAM Module

Manages GCP service accounts, least-privilege IAM role bindings, and Workload Identity Federation (WIF) for keyless GitHub Actions authentication.

## What This Module Creates

| Resource | Purpose |
|----------|---------|
| **Vertex AI Service Account** | Runs Vertex AI training, prediction, and pipeline workloads |
| **CI/CD Service Account** | Used by GitHub Actions for deployments and artifact management |
| **IAM Role Bindings** | Least-privilege roles for each service account |
| **Workload Identity Pool** | OIDC-based identity federation pool for GitHub Actions |
| **Workload Identity Provider** | GitHub Actions OIDC token provider with org-level restriction |
| **WIF ↔ SA Binding** | Allows the specified GitHub repo to impersonate the CI/CD SA |

## Usage

```hcl
module "iam" {
  source = "./modules/iam"

  project_id  = "my-gcp-project"
  name_prefix = "mlops"
  github_org  = "my-org"
  github_repo = "my-ml-repo"

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

### GitHub Actions Workflow

Use the outputs to configure keyless authentication in your workflow:

```yaml
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: ${{ secrets.WIF_PROVIDER }}  # wif_provider_name output
          service_account: ${{ secrets.CICD_SA_EMAIL }}             # cicd_sa_email output
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project ID where IAM resources will be created. | `string` | — | yes |
| `name_prefix` | Prefix for resource names (service accounts, WIF pool, etc.). | `string` | `"mlops"` | no |
| `github_org` | GitHub organization or username that owns the repository. | `string` | — | yes |
| `github_repo` | GitHub repository name (without the org/owner prefix). | `string` | — | yes |
| `labels` | Labels to apply to resources that support them. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vertex_sa_email` | Email address of the Vertex AI service account. |
| `vertex_sa_name` | Fully-qualified resource name of the Vertex AI service account. |
| `cicd_sa_email` | Email address of the CI/CD service account. |
| `cicd_sa_name` | Fully-qualified resource name of the CI/CD service account. |
| `wif_pool_name` | Fully-qualified resource name of the Workload Identity Pool. |
| `wif_provider_name` | Fully-qualified resource name of the Workload Identity Provider. |
