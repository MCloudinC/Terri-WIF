# GCP Workload Identity Federation (WIF) Terraform Configuration

This Terraform configuration sets up Workload Identity Federation in Google Cloud Platform, allowing external identities (GitHub Actions, AWS, SAML providers) to authenticate with GCP without using service account keys.

## Prerequisites

1. **GCP Project**: You need an existing GCP project with billing enabled
2. **Terraform**: Install Terraform (version >= 1.0)
3. **GCP CLI**: Install and configure gcloud CLI
4. **Required APIs**: Enable the following APIs in your GCP project:
   - IAM API
   - Security Token Service API
   - IAM Service Account Credentials API

## Step-by-Step Setup Instructions

### Step 1: Enable Required APIs

```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Enable required APIs
gcloud services enable iam.googleapis.com \
  sts.googleapis.com \
  iamcredentials.googleapis.com \
  --project=$PROJECT_ID
```

### Step 2: Set Up Authentication

```bash
# Authenticate with GCP
gcloud auth login

# Set default project
gcloud config set project $PROJECT_ID

# Create application default credentials for Terraform
gcloud auth application-default login
```

### Step 3: Configure Terraform Variables

1. Copy the example tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your specific configuration:
   - Update `project_id` with your GCP project ID
   - Configure pool and provider settings
   - Choose your provider type (oidc, aws, or saml)
   - Set appropriate attribute mappings
   - Configure service account roles

### Step 4: Initialize Terraform

```bash
terraform init
```

### Step 5: Review the Plan

```bash
terraform plan
```

Review the resources that will be created:
- Workload Identity Pool
- Workload Identity Provider
- Service Account (if enabled)
- IAM bindings

### Step 6: Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to create the resources.

### Step 7: Note the Outputs

After successful deployment, Terraform will output important values:
- Pool ID and name
- Provider ID and name
- Service account email
- Provider path for external configuration

## Configuration Examples

### Example 1: GitHub Actions OIDC

```hcl
provider_type = "oidc"
oidc_issuer_uri = "https://token.actions.githubusercontent.com"
oidc_allowed_audiences = ["https://github.com/your-org/your-repo"]

attribute_mapping = {
  "google.subject"       = "assertion.sub"
  "attribute.repository" = "assertion.repository"
  "attribute.actor"      = "assertion.actor"
}

# Optional: Restrict to specific repository
attribute_condition = "assertion.repository == 'your-org/your-repo'"
```

### Example 2: AWS Provider

```hcl
provider_type = "aws"
aws_account_id = "123456789012"

attribute_mapping = {
  "google.subject"     = "assertion.arn"
  "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
}
```

### Example 3: SAML Provider

```hcl
provider_type = "saml"
saml_idp_metadata_xml = file("saml-metadata.xml")

attribute_mapping = {
  "google.subject" = "assertion.NameID"
  "attribute.email" = "assertion.email"
}
```

## Using WIF with External Services

### GitHub Actions

Add this to your GitHub Actions workflow:

```yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v1
  with:
    workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID'
    service_account: 'SERVICE_ACCOUNT_EMAIL'
```

### AWS

Configure AWS to assume the workload identity:

```bash
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::ACCOUNT:role/ROLE \
  --role-session-name SESSION_NAME \
  --web-identity-token TOKEN
```

## Security Best Practices

1. **Use Attribute Conditions**: Always use attribute conditions to restrict access to specific external identities
2. **Principle of Least Privilege**: Grant only the minimum required IAM roles
3. **Regular Audits**: Regularly review and audit workload identity pool access
4. **Monitor Usage**: Set up monitoring and alerts for WIF usage
5. **Rotate Providers**: Periodically review and update provider configurations

## Troubleshooting

### Common Issues

1. **API Not Enabled Error**
   - Solution: Enable required APIs using the gcloud commands in Step 1

2. **Permission Denied**
   - Solution: Ensure your user has the `roles/iam.workloadIdentityPoolAdmin` role

3. **Invalid Attribute Mapping**
   - Solution: Verify that attribute names match the external identity provider's claims

4. **Provider Not Working**
   - Solution: Check that the issuer URI and audiences match exactly with the external provider

### Debugging Commands

```bash
# Get pool details
gcloud iam workload-identity-pools describe POOL_ID \
  --location=global \
  --project=$PROJECT_ID

# Get provider details
gcloud iam workload-identity-pools providers describe PROVIDER_ID \
  --workload-identity-pool=POOL_ID \
  --location=global \
  --project=$PROJECT_ID

# List service account IAM bindings
gcloud iam service-accounts get-iam-policy SERVICE_ACCOUNT_EMAIL
```

## Clean Up

To remove all resources created by this Terraform configuration:

```bash
terraform destroy
```

Type `yes` when prompted to destroy the resources.

## Additional Resources

- [GCP Workload Identity Federation Documentation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GitHub Actions OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

## File Structure

```
.
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── terraform.tfvars.example   # Example variables file
├── terraform.tfvars          # Your actual variables (create from example)
└── README.md                 # This file
```

## License

This configuration is provided as-is for use in your projects.
