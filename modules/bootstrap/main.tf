# Bootstrap module — enables required GCP APIs and creates the Terraform state bucket.

locals {
  # APIs to enable on the project.
  apis = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "artifactregistry.googleapis.com",
    "aiplatform.googleapis.com",
    "monitoring.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com",
    "billingbudgets.googleapis.com",
  ])
}

# ---------------------------------------------------------------------------
# API enablement
# ---------------------------------------------------------------------------
resource "google_project_service" "apis" {
  for_each = local.apis

  project = var.project_id
  service = each.value

  # Don't disable the API when this resource is destroyed — other project
  # resources may still depend on it.
  disable_on_destroy = false
}

# ---------------------------------------------------------------------------
# Terraform remote-state bucket
# ---------------------------------------------------------------------------
resource "google_storage_bucket" "tfstate" {
  name     = "${var.project_id}-tfstate"
  project  = var.project_id
  location = var.region
  labels   = var.labels

  # Versioning lets us recover previous state files if needed.
  versioning {
    enabled = true
  }

  # Recommended: uniform bucket-level access instead of per-object ACLs.
  uniform_bucket_level_access = true

  # Protect the state bucket from accidental deletion.
  force_destroy = false

  # Clean up old state versions after 30 days to control storage costs.
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
    }
    action {
      type = "Delete"
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [google_project_service.apis]
}
