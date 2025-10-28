output "pool_id" {
  description = "The ID of the workload identity pool"
  value       = google_iam_workload_identity_pool.pool.id
}

output "pool_name" {
  description = "The full resource name of the workload identity pool"
  value       = google_iam_workload_identity_pool.pool.name
}

output "provider_id" {
  description = "The ID of the workload identity provider"
  value       = google_iam_workload_identity_pool_provider.provider.id
}

output "provider_name" {
  description = "The full resource name of the workload identity provider"
  value       = google_iam_workload_identity_pool_provider.provider.name
}

output "service_account_email" {
  description = "The email of the created service account"
  value       = var.create_service_account ? google_service_account.wif_sa[0].email : null
}

output "service_account_unique_id" {
  description = "The unique ID of the created service account"
  value       = var.create_service_account ? google_service_account.wif_sa[0].unique_id : null
}

output "workload_identity_provider_path" {
  description = "The provider resource path for configuring external tools"
  value       = "projects/${var.project_id}/locations/global/workloadIdentityPools/${var.pool_id}/providers/${var.provider_id}"
}

output "service_account_impersonation_url" {
  description = "The URL to use for service account impersonation"
  value       = var.create_service_account ? "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${google_service_account.wif_sa[0].email}:generateAccessToken" : null
}
