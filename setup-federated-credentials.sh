#!/bin/bash

# Script to create the correct federated credentials for GitHub Actions with environment
# Run this script to fix the OIDC authentication issue with GitHub Actions environments

# Set variables
SUBSCRIPTION_ID="$1" # Pass as first argument
CLIENT_ID="$2"       # Pass as second argument
GITHUB_REPO="$3"     # Pass as third argument, format: owner/repo

if [ -z "$SUBSCRIPTION_ID" ] || [ -z "$CLIENT_ID" ] || [ -z "$GITHUB_REPO" ]; then
  echo "❌ Missing required arguments!"
  echo "Usage: $0 <subscription-id> <client-id> <github-repo>"
  echo "Example: $0 ffbf501f-f220-4b59-8d0a-5068d961cc5f 12345678-1234-1234-1234-123456789012 hiddedesmet/terraform-github-actions"
  exit 1
fi

echo "👉 Using Azure subscription: $SUBSCRIPTION_ID"
echo "👉 Using client ID: $CLIENT_ID"
echo "👉 Using GitHub repo: $GITHUB_REPO"

# Login to Azure (if not already logged in)
echo "🔐 Logging in to Azure..."
az account show &> /dev/null || az login

# Set the subscription
echo "🎯 Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Create federated credentials for GitHub Actions
echo "🔄 Creating federated credentials for GitHub Actions main branch..."
az ad app federated-credential create \
  --id "$CLIENT_ID" \
  --parameters "{\"name\":\"github-federated-main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GITHUB_REPO:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

echo "🔄 Creating federated credentials for GitHub Actions pull requests..."
az ad app federated-credential create \
  --id "$CLIENT_ID" \
  --parameters "{\"name\":\"github-federated-pr\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GITHUB_REPO:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

echo "🔄 Creating federated credentials for GitHub Actions dev environment..."
az ad app federated-credential create \
  --id "$CLIENT_ID" \
  --parameters "{\"name\":\"github-federated-env-dev\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:$GITHUB_REPO:environment:dev\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

echo "✅ Federated credentials created successfully!"
echo ""
echo "📋 The following federated credentials have been created:"
echo "1. github-federated-main: For push events to the main branch"
echo "2. github-federated-pr: For pull request events"
echo "3. github-federated-env-dev: For the 'dev' environment in GitHub Actions"
echo ""
echo "🚀 Your GitHub Actions workflow should now work correctly."
