# =============================================================================
# Outputs — Storage Module
# =============================================================================

# --- Data Bucket ---

output "data_bucket_name" {
  description = "Name of the GCS bucket for training datasets."
  value       = google_storage_bucket.data.name
}

output "data_bucket_url" {
  description = "GCS URL of the data bucket (gs://...)."
  value       = "gs://${google_storage_bucket.data.name}"
}

# --- Models Bucket ---

output "models_bucket_name" {
  description = "Name of the GCS bucket for trained model artifacts."
  value       = google_storage_bucket.models.name
}

output "models_bucket_url" {
  description = "GCS URL of the models bucket (gs://...)."
  value       = "gs://${google_storage_bucket.models.name}"
}

# --- Staging Bucket ---

output "staging_bucket_name" {
  description = "Name of the GCS bucket for temporary processing files."
  value       = google_storage_bucket.staging.name
}

output "staging_bucket_url" {
  description = "GCS URL of the staging bucket (gs://...)."
  value       = "gs://${google_storage_bucket.staging.name}"
}
