#!/bin/bash

# Script to gather information about existing Azure backend resources for Terraform

# Set subscription ID
SUBSCRIPTION_ID="ffbf501f-f220-4b59-8d0a-5068d961cc5f"

# Login to Azure (if not already logged in)
echo "🔐 Checking Azure login status..."
az account show &> /dev/null || az login

# Set subscription
echo "🎯 Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Find resource groups that might contain Terraform state resources
echo "🔍 Looking for resource groups that might contain Terraform state resources..."
POSSIBLE_RGS=$(az group list --query "[?contains(name, 'terraform') || contains(name, 'tfstate')].name" -o tsv)

if [ -z "$POSSIBLE_RGS" ]; then
  echo "❓ No resource groups with 'terraform' or 'tfstate' in the name were found."
  echo "   Listing all resource groups instead:"
  az group list --query "[].name" -o tsv
else
  echo "✅ Found potential resource groups for Terraform state:"
  echo "$POSSIBLE_RGS"
  
  # For each potential resource group, find storage accounts
  for RG in $POSSIBLE_RGS; do
    echo ""
    echo "🔍 Checking storage accounts in resource group '$RG'..."
    STORAGE_ACCOUNTS=$(az storage account list --resource-group "$RG" --query "[].name" -o tsv)
    
    if [ -z "$STORAGE_ACCOUNTS" ]; then
      echo "   No storage accounts found in $RG"
    else
      echo "✅ Found storage accounts in $RG:"
      echo "$STORAGE_ACCOUNTS"
      
      # For each storage account, check for containers named tfstate or similar
      for SA in $STORAGE_ACCOUNTS; do
        echo ""
        echo "🔍 Checking containers in storage account '$SA'..."
        # Get account key
        SA_KEY=$(az storage account keys list --resource-group "$RG" --account-name "$SA" --query "[0].value" -o tsv)
        
        # List containers
        CONTAINERS=$(az storage container list --account-name "$SA" --account-key "$SA_KEY" --query "[?contains(name, 'tfstate') || contains(name, 'terraform')].name" -o tsv)
        
        if [ -z "$CONTAINERS" ]; then
          echo "   No containers with 'tfstate' or 'terraform' in the name were found in $SA"
          echo "   Listing all containers instead:"
          az storage container list --account-name "$SA" --account-key "$SA_KEY" --query "[].name" -o tsv
        else
          echo "✅ Found potential Terraform state containers in $SA:"
          echo "$CONTAINERS"
          
          # Output backend configuration for this storage account and containers
          for CONTAINER in $CONTAINERS; do
            echo ""
            echo "📋 Terraform Backend Configuration for: $SA / $CONTAINER"
            echo "--------------------------------------------------------"
            echo "terraform {"
            echo "  backend \"azurerm\" {"
            echo "    resource_group_name  = \"$RG\""
            echo "    storage_account_name = \"$SA\""
            echo "    container_name       = \"$CONTAINER\""
            echo "    key                  = \"terraform-github-actions.tfstate\""
            echo "  }"
            echo "}"
          done
        fi
      done
    fi
  done
fi
