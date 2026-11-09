# -----------------------------------------------------------------------------
# Service Accounts
# -----------------------------------------------------------------------------

resource "google_service_account" "vertex_ai" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-vertex-sa"
  display_name = "Vertex AI Service Account"
  description  = "Service account for Vertex AI operations (training, prediction, pipelines)."
}

resource "google_service_account" "cicd" {
  project      = var.project_id
  account_id   = "${var.name_prefix}-cicd-sa"
  display_name = "CI/CD Service Account"
  description  = "Service account for GitHub Actions CI/CD pipelines."
}

# -----------------------------------------------------------------------------
# IAM Role Bindings — Vertex AI SA (least-privilege)
# -----------------------------------------------------------------------------

locals {
  vertex_sa_roles = [
    "roles/aiplatform.user",       # Manage Vertex AI resources
    "roles/storage.objectAdmin",   # Read/write model artifacts and data in GCS
    "roles/artifactregistry.reader", # Pull container images
  ]

  cicd_sa_roles = [
    "roles/aiplatform.admin",          # Deploy models
    "roles/storage.admin",             # Upload/manage artifacts
    "roles/artifactregistry.writer",   # Push container images
    "roles/cloudbuild.builds.editor",  # Submit builds
  ]
}

resource "google_project_iam_member" "vertex_ai_roles" {
  for_each = toset(local.vertex_sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vertex_ai.email}"
}

resource "google_project_iam_member" "cicd_roles" {
  for_each = toset(local.cicd_sa_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

# Allow the CI/CD SA to act as the Vertex AI SA during deployments
resource "google_project_iam_member" "cicd_act_as_vertex" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cicd.email}"
}

# -----------------------------------------------------------------------------
# Workload Identity Federation — GitHub Actions OIDC
# -----------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "${var.name_prefix}-github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions OIDC authentication."
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.name_prefix}-github-provider"
  display_name                       = "GitHub Actions OIDC Provider"
  description                        = "OIDC provider for GitHub Actions token exchange."

  # Restrict token exchange to the specified GitHub organization
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allow GitHub Actions from the specified repo to impersonate the CI/CD SA
resource "google_service_account_iam_member" "cicd_wif_binding" {
  service_account_id = google_service_account.cicd.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/${var.github_repo}"
}
