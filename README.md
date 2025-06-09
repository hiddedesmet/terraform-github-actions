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
  - `terraform-destroy.yml` - Workflow for safely destroying resources
- `modules/storage-account/` - Custom module for Azure Storage Account

## Prerequisites

To use this repository, you'll need:

1. An Azure subscription
2. GitHub repository
3. Service principal with Contributor permissions on your Azure subscription

## Setup Instructions

### 1. Setting Up Azure Backend and Service Principal

This repository includes setup scripts that help you create all necessary resources and permissions:

#### 1.1 Setting up the backend infrastructure

The `setup-azure-backend.sh` script:
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

#### 1.2 Setting up federated credentials for GitHub Actions environments

The `setup-federated-credentials.sh` script creates the necessary federation credentials for GitHub Actions, including the specific format needed for GitHub environments:

```bash
./setup-federated-credentials.sh <SUBSCRIPTION_ID> <CLIENT_ID> <GITHUB_REPO>
```

For example:
```bash
./setup-federated-credentials.sh ffbf501f-f220-4b59-8d0a-5068d961cc5f 12345678-1234-1234-1234-123456789012 hiddedesmet/terraform-github-actions
```

This will create three different federated credentials:
1. For pushes to the main branch: `repo:owner/repo:ref:refs/heads/main`
2. For pull requests: `repo:owner/repo:pull_request`
3. For the dev environment: `repo:owner/repo:environment:dev`

### 2. Configure GitHub Repository Secrets

Add the following secrets to your GitHub repository:

- `AZURE_CLIENT_ID`: Service principal client ID (output by setup script)
- `AZURE_TENANT_ID`: Azure tenant ID (output by setup script)
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID (output by setup script)

All Azure credentials are securely stored as GitHub secrets.

### 3. Environment-Specific Terraform Variables

This repository follows best practices for handling Terraform variables in CI/CD:

#### In GitHub Actions Workflows:

The workflow uses a combination of two approaches:

1. **Environment Variables**: Simple variables are set using the `TF_VAR_` prefix, which Terraform automatically recognizes. This is the recommended approach for most variables.

2. **Generated tfvars File**: Complex variables (like maps and lists) that are harder to express as environment variables are generated in a small `complex_vars.tfvars` file during the workflow execution.

This hybrid approach provides several benefits:
- Simple variables are easily visible in the workflow logs
- No need to commit environment-specific files to the repository
- Works well with GitHub environments and secrets
- Complex data structures are still supported

#### For Local Development:

You can create a `terraform.tfvars` file for local use:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred values
```

For consistency with the CI/CD pipeline, you can also use environment variables:

```bash
export TF_VAR_resource_group_name="rg-terraform-demo-dev"
terraform plan
```

For a detailed overview of best practices and different approaches to managing Terraform variables in CI/CD, see [Terraform Variables Best Practices](docs/terraform-variables-best-practices.md).

### 4. Push to GitHub

Push the code to your GitHub repository:

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

## Workflow Execution

This repository contains three GitHub Actions workflows:

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

### Destroy Workflow (`terraform-destroy.yml`)

This workflow is manually triggered and includes safety mechanisms for resource cleanup:

1. Manual trigger only with required confirmation:
   - Must explicitly type "destroy" to confirm
   - Must select target environment (dev, test, prod)

2. When executed:
   - Creates a destroy plan
   - Displays a 30-second warning with abort option
   - Executes the destroy operation
   - Verifies resource deletion and reports any remaining resources

## Clean Up

When you're done with the demo, you can clean up resources using either method:

### Option 1: Using GitHub Actions (Recommended)

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Terraform Destroy" workflow
3. Click "Run workflow"
4. Select the target environment (dev, test, prod)
5. Type "destroy" in the confirmation field
6. Click "Run workflow"

The workflow includes safety measures and verification steps to ensure proper resource cleanup.

### Option 2: Using Local Terraform

Run the destroy command locally:

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