# Terraform GitHub Actions Demo

This repository demonstrates a simple CI/CD pipeline for Terraform using GitHub Actions. It deploys a basic infrastructure configuration to Azure, creating a resource group and a storage account with configurable settings.

## Project Overview

This demo shows how to:

1. Set up GitHub Actions workflow for Terraform CI/CD
2. Use workload identity federation (OIDC) for secure authentication to Azure
3. Automate Terraform validation, planning, and deployment
4. Provide plan output as PR comments for better visibility and review

## Repository Structure

- `main.tf` - Main Terraform configuration
- `variables.tf` - Input variables declaration
- `outputs.tf` - Output variables declaration
- `terraform.tfvars.example` - Example values for Terraform variables
- `backend.tf` - Configuration for Terraform remote state (commented by default)
- `.github/workflows/` - GitHub Actions workflows:
  - `terraform-deploy.yml` - Main deployment workflow for the main branch
  - `terraform-validate.yml` - Validation workflow for feature branches
- `modules/storage-account/` - Custom module for Azure Storage Account

## Prerequisites

To use this repository, you'll need:

1. An Azure subscription
2. GitHub repository
3. Service principal with Contributor permissions on your Azure subscription

## Setup Instructions

### 1. Setting Up Azure Backend and Service Principal

This repository includes a setup script that:
- Creates a storage account and container for Terraform state
- Creates a service principal with OIDC authentication for GitHub Actions
- Configures all necessary permissions
- Outputs all required configuration values

Run the script to set up everything in one command:

```bash
./setup-azure-backend.sh
```

The script will output all the values you need:
- Backend configuration values for backend.tf
- GitHub secrets to configure

### 2. Configure GitHub Repository Secrets

Add the following secrets to your GitHub repository:

- `AZURE_CLIENT_ID`: Service principal client ID (output by setup script)
- `AZURE_TENANT_ID`: Azure tenant ID (output by setup script)
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID (output by setup script)

All Azure credentials are securely stored as GitHub secrets.

### 3. Environment-Specific Terraform Variables

This repository is set up with environment-specific variable files:

- `dev.tfvars` - Contains variables for the development environment

The GitHub Actions workflow automatically uses the `dev.tfvars` file when deploying to the `dev` environment.

For local development, you can create a `terraform.tfvars` file:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred values
```

Or use the environment-specific file:

```bash
terraform plan -var-file=dev.tfvars
```

### 4. Push to GitHub

Push the code to your GitHub repository:

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

## Workflow Execution

This repository contains two GitHub Actions workflows:

### Main Deployment Workflow (`terraform-deploy.yml`)

This workflow runs on the main branch and handles deployment:

1. On pull requests to main:
   - Validate Terraform configuration
   - Create a plan and add it as a PR comment for review

2. On push to main:
   - Validate Terraform configuration 
   - Create a plan
   - Apply the plan to deploy resources to Azure

### Validation Workflow (`terraform-validate.yml`)

This workflow runs on all non-main branches:

1. On push to any branch except main:
   - Validate Terraform configuration syntax and structure
   - Check Terraform formatting

## Clean Up

When you're done with the demo, remember to destroy the resources to avoid unnecessary costs:

```bash
terraform destroy -auto-approve
```

## Remote State Management

This repository is configured to use Azure Storage for remote Terraform state management. The setup is handled by the `setup-azure-backend.sh` script and configured in the `backend.tf` file.

To enable remote state:

1. Run the setup script that creates all necessary Azure resources:
   ```bash
   ./setup-azure-backend.sh
   ```

2. Update the `backend.tf` file with the values output by the script and uncomment the backend configuration

3. Run `terraform init` to initialize the backend:
   ```bash
   terraform init
   ```

The backend configuration uses the Azure CLI credentials when running locally, and the GitHub Actions OIDC credentials when running in CI/CD, so you don't need to manage storage access keys.

## Security Best Practices

This demo incorporates several security best practices:

1. Using OIDC for authentication instead of long-lived secrets
2. Storage account configured with secure defaults:
   - TLS 1.2 enforcement
   - Public blob access disabled
   - Versioning enabled
   - Soft delete protection
3. Support for remote state management
4. GitHub Actions workflow with proper permissions scoping

## License

[MIT License](LICENSE)