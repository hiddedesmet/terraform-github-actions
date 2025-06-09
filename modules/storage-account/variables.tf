# Variables for the Storage Account module

variable "name" {
  description = "Base name for the storage account (will have random suffix added)"
  type        = string
  
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 16
    error_message = "Storage account base name must be between 3 and 16 characters (random suffix will be added)."
  }
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.name))
    error_message = "Storage account name can only contain lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the storage account will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the storage account will be deployed"
  type        = string
}

variable "account_tier" {
  description = "Performance tier of the storage account"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Storage account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Replication type for the storage account"
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "enable_versioning" {
  description = "Enable blob versioning for the storage account"
  type        = bool
  default     = true
}

variable "enable_delete_retention" {
  description = "Enable soft delete for blobs and containers"
  type        = bool
  default     = true
}

variable "delete_retention_days" {
  description = "Number of days to retain deleted blobs and containers"
  type        = number
  default     = 7
  
  validation {
    condition     = var.delete_retention_days >= 1 && var.delete_retention_days <= 365
    error_message = "Delete retention days must be between 1 and 365."
  }
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}
