# =============================================================================
# Root Module — Iris Classifier End-to-End MLOps Example on GCP
# =============================================================================
# Provisions complete production-ready MLOps infrastructure:
# - API Bootstrap & Terraform Remote State
# - Custom VPC with Private Google Access & Cloud NAT
# - IAM Service Accounts & Keyless GitHub Workload Identity Federation
# - Artifact Registry for Docker images
# - Storage Buckets (Data, Models, Staging) with auto-tiering & lifecycle rules
# - Vertex AI Endpoint & Model Registry
# - Optional Cost Guardrail (Monthly Budget Alert)
# =============================================================================

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.15"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -----------------------------------------------------------------------------
# 1. Foundation: Bootstrap GCP APIs & State Storage
# -----------------------------------------------------------------------------
module "bootstrap" {
  source = "../../modules/bootstrap"

  project_id = var.project_id
  region     = var.region
  labels     = var.labels
}

# -----------------------------------------------------------------------------
# 2. Foundation: VPC Networking & NAT
# -----------------------------------------------------------------------------
module "network" {
  source = "../../modules/network"

  project_id  = var.project_id
  region      = var.region
  name_prefix = var.name_prefix
  subnet_cidr = "10.0.0.0/24"
  labels      = var.labels

  depends_on = [module.bootstrap]
}

# -----------------------------------------------------------------------------
# 3. Foundation: IAM & Workload Identity Federation for GitHub Actions
# -----------------------------------------------------------------------------
module "iam" {
  source = "../../modules/iam"

  project_id  = var.project_id
  name_prefix = var.name_prefix
  github_org  = var.github_org
  github_repo = var.github_repo
  labels      = var.labels

  depends_on = [module.bootstrap]
}

# -----------------------------------------------------------------------------
# 4. Storage: Artifact Registry for Container Images
# -----------------------------------------------------------------------------
module "registry" {
  source = "../../modules/registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "${var.name_prefix}-containers"
  cleanup_days  = 30
  labels        = var.labels

  depends_on = [module.bootstrap]
}

# -----------------------------------------------------------------------------
# 5. Storage: GCS Buckets for Data, Models, and Ephemeral Staging
# -----------------------------------------------------------------------------
module "storage" {
  source = "../../modules/storage"

  project_id    = var.project_id
  region        = var.region
  name_prefix   = var.name_prefix
  environment   = var.environment
  force_destroy = var.environment == "dev"
  labels        = var.labels

  depends_on = [module.bootstrap]
}

# -----------------------------------------------------------------------------
# 6. ML Platform: Vertex AI Endpoint & Model Registration
# -----------------------------------------------------------------------------
locals {
  serving_image_uri = "${module.registry.registry_url}/iris-predictor:${var.container_image_tag}"
}

module "vertex_endpoint" {
  source = "../../modules/vertex-endpoint"

  project_id            = var.project_id
  region                = var.region
  endpoint_display_name = "${var.name_prefix}-endpoint"
  model_display_name    = "${var.name_prefix}-iris-model"
  model_description     = "Iris Classifier RandomForest model deployed via MLOps-in-a-Box"
  container_image_uri   = local.serving_image_uri
  artifact_uri          = "${module.storage.models_bucket_url}/iris"
  predict_route         = "/predict"
  health_route          = "/health"
  labels                = var.labels

  depends_on = [module.bootstrap, module.registry, module.storage]
}

# -----------------------------------------------------------------------------
# 7. Cost Guardrails: Optional Billing Budget Alerts
# -----------------------------------------------------------------------------
module "budget" {
  count  = var.enable_budget && var.billing_account != "" ? 1 : 0
  source = "../../modules/budget"

  project_id         = var.project_id
  billing_account    = var.billing_account
  name_prefix        = var.name_prefix
  monthly_budget_usd = var.monthly_budget_usd
  alert_email        = var.alert_email
  labels             = var.labels

  depends_on = [module.bootstrap]
}
