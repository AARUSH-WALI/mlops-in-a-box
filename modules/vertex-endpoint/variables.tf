# -----------------------------------------------------------------------------
# Variables — Vertex AI Endpoint & Model Module
# -----------------------------------------------------------------------------

variable "project_id" {
  description = "The GCP project ID where Vertex AI resources will be deployed."
  type        = string
}

variable "region" {
  description = "The GCP region for Vertex AI resources (e.g., us-central1)."
  type        = string
  default     = "us-central1"
}

variable "endpoint_display_name" {
  description = "Display name for the Vertex AI prediction endpoint."
  type        = string
  default     = "mlops-prediction-endpoint"
}

variable "model_display_name" {
  description = "Display name for the Vertex AI model registered in Model Registry."
  type        = string
  default     = "iris-classifier"
}

variable "model_description" {
  description = "Description for the registered Vertex AI model."
  type        = string
  default     = "Production ML model deployed via MLOps-in-a-Box"
}

variable "container_image_uri" {
  description = "The container image URI in Artifact Registry used for serving predictions."
  type        = string
}

variable "artifact_uri" {
  description = "Optional GCS URI containing model artifacts (e.g., gs://bucket/model.joblib)."
  type        = string
  default     = ""
}

variable "predict_route" {
  description = "HTTP path for prediction requests on the serving container."
  type        = string
  default     = "/predict"
}

variable "health_route" {
  description = "HTTP path for health check requests on the serving container."
  type        = string
  default     = "/health"
}

variable "network_id" {
  description = "Optional full resource name of the VPC network for private endpoint deployment."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to attach to the endpoint and model."
  type        = map(string)
  default     = {}
}
