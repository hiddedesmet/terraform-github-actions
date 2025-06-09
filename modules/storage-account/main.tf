# Storage Account Module
# This module creates an Azure Storage Account with configurable settings

terraform {
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

# Generate a random suffix to ensure storage account name uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the storage account
resource "azurerm_storage_account" "this" {
  name                = "${var.name}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind            = "StorageV2"

  # Security settings
  min_tls_version                = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true

  # Blob properties for modern workloads
  blob_properties {
    versioning_enabled = var.enable_versioning
    
    dynamic "delete_retention_policy" {
      for_each = var.enable_delete_retention ? [1] : []
      content {
        days = var.delete_retention_days
      }
    }
    
    dynamic "container_delete_retention_policy" {
      for_each = var.enable_delete_retention ? [1] : []
      content {
        days = var.delete_retention_days
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags that might be added by Azure Policy
      tags
    ]
  }
}
