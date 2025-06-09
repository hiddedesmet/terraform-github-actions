# Output values from the Terraform deployment

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.demo.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.demo.location
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account.id
}

output "storage_account_primary_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage_account.primary_blob_endpoint
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = module.storage_account.primary_connection_string
  sensitive   = true
}

output "storage_account_access_keys" {
  description = "Access keys for the storage account"
  value       = module.storage_account.primary_access_key
  sensitive   = true
}
