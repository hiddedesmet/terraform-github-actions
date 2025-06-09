#!/bin/bash

# Script to create Azure backend resources for Terraform state storage
# and generate the required secrets for GitHub Actions

# Set variables
SUBSCRIPTION_ID="ffbf501f-f220-4b59-8d0a-5068d961cc5f"
RESOURCE_GROUP="rg-terraform-state"
LOCATION="westeurope"
STORAGE_ACCOUNT_NAME="tfstate$RANDOM$RANDOM"  # Using random suffix for uniqueness
CONTAINER_NAME="tfstate"
SERVICE_PRINCIPAL_NAME="sp-github-terraform-actions"
GITHUB_REPO="hiddedesmet/terraform-github-actions"  # Using your GitHub username from the filepath

echo "👉 Using Azure subscription: $SUBSCRIPTION_ID"

# Login to Azure (if not already logged in)
echo "🔐 Logging in to Azure..."
az account show &> /dev/null || az login

# Set the subscription
echo "🎯 Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create a resource group for Terraform state
echo "📦 Creating resource group: $RESOURCE_GROUP..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Create storage account for Terraform state
echo "💾 Creating storage account: $STORAGE_ACCOUNT_NAME..."
az storage account create \
  --name "$STORAGE_ACCOUNT_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false

# Get storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT_NAME" --query '[0].value' -o tsv)

# Create container
echo "🪣 Creating container: $CONTAINER_NAME..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$STORAGE_ACCOUNT_KEY"

# Create service principal with Contributor role
echo "👤 Creating service principal: $SERVICE_PRINCIPAL_NAME..."
SP_INFO=$(az ad sp create-for-rbac \
  --name "$SERVICE_PRINCIPAL_NAME" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --years 1)

CLIENT_ID=$(echo $SP_INFO | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_INFO | jq -r '.password')
TENANT_ID=$(echo $SP_INFO | jq -r '.tenant')

# Add federated credentials for GitHub Actions
echo "🔄 Creating federated credentials for GitHub Actions..."
az ad app federated-credential create \
  --id "$CLIENT_ID" \
  --parameters "{\"name\":\"github-federated-main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GITHUB_REPO:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
  --id "$CLIENT_ID" \
  --parameters "{\"name\":\"github-federated-pr\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GITHUB_REPO:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Output results
echo "✅ Azure Backend Setup Complete!"
echo ""
echo "📋 Backend Configuration:"
echo "-----------------------------------"
echo "STORAGE_ACCOUNT_NAME: $STORAGE_ACCOUNT_NAME"
echo "CONTAINER_NAME: $CONTAINER_NAME"
echo "RESOURCE_GROUP: $RESOURCE_GROUP"
echo "KEY: terraform-github-actions.tfstate"
echo ""
echo "📋 GitHub Secrets:"
echo "-----------------------------------"
echo "AZURE_CLIENT_ID: $CLIENT_ID"
echo "AZURE_TENANT_ID: $TENANT_ID"
echo ""
echo "⚠️ Note: The storage account key is not shown for security reasons."
echo "It's not needed for GitHub Actions when using OIDC authentication."
echo ""
echo "💡 Uncomment the backend configuration in backend.tf and update with:"
echo "storage_account_name  = \"$STORAGE_ACCOUNT_NAME\""
echo "container_name       = \"$CONTAINER_NAME\""
echo "key                  = \"terraform-github-actions.tfstate\""
echo "resource_group_name  = \"$RESOURCE_GROUP\""
echo ""
echo "🔒 Remember to add AZURE_CLIENT_ID and AZURE_TENANT_ID as secrets in your GitHub repository."
