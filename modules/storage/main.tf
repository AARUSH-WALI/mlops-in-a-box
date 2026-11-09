# =============================================================================
# GCS Buckets for ML Pipeline Storage
# =============================================================================
# Creates three purpose-specific buckets:
#   - Data bucket:    training datasets (versioned, persistent)
#   - Models bucket:  trained model artifacts (versioned, lifecycle to NEARLINE)
#   - Staging bucket: temporary processing files (auto-deleted after 7 days)
# =============================================================================

locals {
  data_bucket_name    = "${var.project_id}-${var.name_prefix}-data-${var.environment}"
  models_bucket_name  = "${var.project_id}-${var.name_prefix}-models-${var.environment}"
  staging_bucket_name = "${var.project_id}-${var.name_prefix}-staging-${var.environment}"

  common_labels = merge(var.labels, {
    managed_by  = "terraform"
    environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# Data Bucket — Training Datasets
# -----------------------------------------------------------------------------
# Versioning enabled to protect against accidental overwrites of datasets.
resource "google_storage_bucket" "data" {
  name     = local.data_bucket_name
  project  = var.project_id
  location = var.region

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy

  versioning {
    enabled = true
  }

  labels = merge(local.common_labels, {
    purpose = "training-data"
  })
}

# -----------------------------------------------------------------------------
# Models Bucket — Trained Model Artifacts
# -----------------------------------------------------------------------------
# Versioning enabled to keep old model versions for rollback.
# Lifecycle rule transitions objects to NEARLINE after 90 days to reduce
# storage costs for older model versions that are infrequently accessed.
resource "google_storage_bucket" "models" {
  name     = local.models_bucket_name
  project  = var.project_id
  location = var.region

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
    condition {
      age = 90 # days — archive old model versions to cheaper storage
    }
  }

  labels = merge(local.common_labels, {
    purpose = "model-artifacts"
  })
}

# -----------------------------------------------------------------------------
# Staging Bucket — Temporary Processing Files
# -----------------------------------------------------------------------------
# No versioning — staging data is ephemeral.
# Force destroy is always true since this is temporary data.
# Lifecycle rule auto-deletes objects after 7 days to prevent accumulation.
resource "google_storage_bucket" "staging" {
  name     = local.staging_bucket_name
  project  = var.project_id
  location = var.region

  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = true # Always force-destroyable; staging data is disposable

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 7 # days — auto-cleanup of temporary processing files
    }
  }

  labels = merge(local.common_labels, {
    purpose = "staging"
  })
}
