# Main Terraform configuration
# This demo shows how to deploy a simple storage account using a custom module

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  # These are automatically set when using GitHub Actions with OIDC or az login
  # For local development, define them using environment variables:
  # ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_TENANT_ID
  # Or they can be set here (not recommended for production code):
  # subscription_id = "your-subscription-id"
  # client_id       = "your-client-id"
  # tenant_id       = "your-tenant-id"
}

# Create a resource group
resource "azurerm_resource_group" "demo" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Use our custom storage account module
module "storage_account" {
  source = "./modules/storage-account"

  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.demo.name
  location           = azurerm_resource_group.demo.location
  
  # Storage account configuration
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  
  # Enable blob properties for modern workloads
  enable_versioning        = var.enable_blob_versioning
  enable_delete_retention  = var.enable_delete_retention
  delete_retention_days    = var.delete_retention_days
  
  tags = var.tags
}
