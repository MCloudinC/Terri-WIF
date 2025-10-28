# Project Configuration
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

# Workload Identity Pool Configuration
variable "pool_id" {
  description = "The ID for the workload identity pool"
  type        = string
}

variable "pool_display_name" {
  description = "Display name for the workload identity pool"
  type        = string
}

variable "pool_description" {
  description = "Description for the workload identity pool"
  type        = string
  default     = ""
}

variable "pool_disabled" {
  description = "Whether the pool is disabled"
  type        = bool
  default     = false
}

# Workload Identity Provider Configuration
variable "provider_id" {
  description = "The ID for the workload identity provider"
  type        = string
}

variable "provider_display_name" {
  description = "Display name for the workload identity provider"
  type        = string
}

variable "provider_description" {
  description = "Description for the workload identity provider"
  type        = string
  default     = ""
}

variable "provider_disabled" {
  description = "Whether the provider is disabled"
  type        = bool
  default     = false
}

variable "provider_type" {
  description = "Type of provider: oidc, aws, or saml"
  type        = string
  validation {
    condition     = contains(["oidc", "aws", "saml"], var.provider_type)
    error_message = "Provider type must be either 'oidc', 'aws', or 'saml'."
  }
}

# Attribute Configuration
variable "attribute_mapping" {
  description = "Attribute mapping from assertion to Google Cloud attributes"
  type        = map(string)
  default = {
    "google.subject" = "assertion.sub"
  }
}

variable "attribute_condition" {
  description = "An optional CEL expression for attribute condition"
  type        = string
  default     = null
}

# OIDC Provider Configuration
variable "oidc_issuer_uri" {
  description = "OIDC issuer URI (required if provider_type is 'oidc')"
  type        = string
  default     = ""
}

variable "oidc_allowed_audiences" {
  description = "List of allowed audiences for OIDC provider"
  type        = list(string)
  default     = []
}

# AWS Provider Configuration
variable "aws_account_id" {
  description = "AWS account ID (required if provider_type is 'aws')"
  type        = string
  default     = ""
}

# SAML Provider Configuration
variable "saml_idp_metadata_xml" {
  description = "SAML IDP metadata XML (required if provider_type is 'saml')"
  type        = string
  default     = ""
}

# Service Account Configuration
variable "create_service_account" {
  description = "Whether to create a service account for workload identity"
  type        = bool
  default     = true
}

variable "service_account_id" {
  description = "The ID for the service account"
  type        = string
  default     = "wif-service-account"
}

variable "service_account_display_name" {
  description = "Display name for the service account"
  type        = string
  default     = "Workload Identity Federation Service Account"
}

variable "service_account_description" {
  description = "Description for the service account"
  type        = string
  default     = "Service account for workload identity federation"
}

variable "service_account_roles" {
  description = "List of IAM roles to grant to the service account"
  type        = list(string)
  default     = []
}

variable "pool_member_binding" {
  description = "Custom member binding for service account IAM (leave empty for default)"
  type        = string
  default     = ""
}
