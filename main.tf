terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create Workload Identity Pool
resource "google_iam_workload_identity_pool" "pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name             = var.pool_display_name
  description              = var.pool_description
  disabled                 = var.pool_disabled
}

# Create Workload Identity Pool Provider
resource "google_iam_workload_identity_pool_provider" "provider" {
  project                            = var.project_id
  workload_identity_pool_id         = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = var.provider_display_name
  description                        = var.provider_description
  disabled                           = var.provider_disabled

  # Attribute mapping
  attribute_mapping = var.attribute_mapping

  # Attribute condition (optional)
  attribute_condition = var.attribute_condition

  # OIDC configuration (if using OIDC)
  dynamic "oidc" {
    for_each = var.provider_type == "oidc" ? [1] : []
    content {
      issuer_uri        = var.oidc_issuer_uri
      allowed_audiences = var.oidc_allowed_audiences
    }
  }

  # AWS configuration (if using AWS)
  dynamic "aws" {
    for_each = var.provider_type == "aws" ? [1] : []
    content {
      account_id = var.aws_account_id
    }
  }

  # SAML configuration (if using SAML)
  dynamic "saml" {
    for_each = var.provider_type == "saml" ? [1] : []
    content {
      idp_metadata_xml = var.saml_idp_metadata_xml
    }
  }
}

# Create Service Account (optional)
resource "google_service_account" "wif_sa" {
  count        = var.create_service_account ? 1 : 0
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
  description  = var.service_account_description
}

# Grant roles to the Service Account
resource "google_project_iam_member" "wif_sa_roles" {
  for_each = var.create_service_account ? toset(var.service_account_roles) : toset([])
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.wif_sa[0].email}"
}

# Allow workload identity pool to impersonate the service account
resource "google_service_account_iam_member" "wif_binding" {
  count              = var.create_service_account ? 1 : 0
  service_account_id = google_service_account.wif_sa[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = var.pool_member_binding != "" ? var.pool_member_binding : "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.pool.name}/*"
}
