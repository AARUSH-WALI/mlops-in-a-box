# Vertex AI Endpoint & Model Module

Terraform module to provision a Google Cloud Vertex AI Online Prediction Endpoint and register a containerized model in the Vertex AI Model Registry.

## Architecture & Design

- **Decoupled Deployment:** The module registers the model and creates the endpoint infrastructure. Actual deployment of a model version to the endpoint (with traffic splitting) is managed by CI/CD workflows, enabling canary deployments, Blue/Green traffic shifts, and instant rollbacks.
- **VPC Peering Support:** Optionally pass `network_id` to attach the endpoint to your VPC with Private Google Access for secure internal inference.

## Usage

```hcl
module "vertex_endpoint" {
  source = "./modules/vertex-endpoint"

  project_id            = "my-gcp-project"
  region                = "us-central1"
  endpoint_display_name = "iris-prediction-endpoint"
  model_display_name    = "iris-classifier"
  container_image_uri   = "us-central1-docker.pkg.dev/my-gcp-project/mlops-containers/iris-classifier:v1.0.0"

  labels = {
    environment = "prod"
    team        = "mlops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | The GCP project ID | `string` | n/a | yes |
| `region` | GCP region for resources | `string` | `"us-central1"` | no |
| `endpoint_display_name` | Display name for the endpoint | `string` | `"mlops-prediction-endpoint"` | no |
| `model_display_name` | Display name for the registered model | `string` | `"iris-classifier"` | no |
| `model_description` | Description of the registered model | `string` | `"Production ML model deployed via MLOps-in-a-Box"` | no |
| `container_image_uri` | Container image URI in Artifact Registry | `string` | n/a | yes |
| `artifact_uri` | Optional GCS path with model artifacts | `string` | `""` | no |
| `predict_route` | HTTP path for prediction requests | `string` | `"/predict"` | no |
| `health_route` | HTTP path for health checks | `string` | `"/health"` | no |
| `network_id` | Optional VPC network resource name | `string` | `null` | no |
| `labels` | Resource labels | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `endpoint_id` | The ID of the created Vertex AI Endpoint |
| `endpoint_name` | The full resource name of the Vertex AI Endpoint |
| `model_id` | The ID of the registered Vertex AI Model |
| `model_name` | The full resource name of the registered Vertex AI Model |
| `endpoint_network` | The VPC network attached to the endpoint (if any) |
