# This file configures the backend for storing Terraform state
# Uncomment this section and update the values to use Azure Storage as your backend

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate839523223"
    container_name       = "tfstate"
    key                  = "terraform-github-actions.tfstate"
  }
}

# Instructions:
# 1. Run the setup-azure-backend.sh script to create the backend resources
# 2. Update the values above with those output by the script
# 3. Uncomment the backend configuration
# 4. Run 'terraform init' to initialize the backend
#
# Note: When using GitHub Actions with OIDC authentication, you don't need to
# provide storage access keys in the backend configuration.
