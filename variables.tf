# Input variables for the Terraform configuration

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-terraform-demo"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stterraformdemo"
  
  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters long."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name can only contain lowercase letters and numbers."
  }
}

variable "storage_account_tier" {
  description = "Performance tier of the storage account"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either 'Standard' or 'Premium'."
  }
}

variable "storage_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning for the storage account"
  type        = bool
  default     = true
}

variable "enable_delete_retention" {
  description = "Enable soft delete for blobs"
  type        = bool
  default     = true
}

variable "delete_retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 7
  
  validation {
    condition     = var.delete_retention_days >= 1 && var.delete_retention_days <= 365
    error_message = "Delete retention days must be between 1 and 365."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "terraform-github-actions"
    ManagedBy   = "terraform"
  }
}
