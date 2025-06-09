# Terraform Variables in CI/CD: Best Practices

This document outlines the different approaches and best practices for handling Terraform variables in CI/CD pipelines, particularly in GitHub Actions.

## Common Approaches

### 1. Environment Variables with TF_VAR_ Prefix

**How it works**: Terraform automatically loads environment variables that start with `TF_VAR_` as input variables.

```yaml
- name: Set Terraform Variables
  run: |
    echo "TF_VAR_resource_group_name=rg-example" >> $GITHUB_ENV
    echo "TF_VAR_location=westeurope" >> $GITHUB_ENV
```

**Pros**:
- Simple and transparent
- Values visible in logs (for non-sensitive data)
- No need for extra files
- Works well with GitHub Environments
- Easy to audit

**Cons**:
- Complex data structures (maps, lists) are harder to represent
- Environment variables are limited in size

### 2. Generated .tfvars Files

**How it works**: The workflow generates a `.tfvars` file dynamically during execution.

```yaml
- name: Create tfvars file
  run: |
    cat > environment.tfvars << 'EOF'
    resource_group_name = "rg-example"
    location = "westeurope"
    EOF
    
    terraform plan -var-file=environment.tfvars
```

**Pros**:
- Supports all Terraform data types
- Can generate different files for different environments
- Familiar format for Terraform users

**Cons**:
- File content needs to be managed in the workflow
- Harder to use with GitHub Secrets for sensitive values

### 3. Committed Environment-Specific Files

**How it works**: Store different `.tfvars` files directly in the repository.

```
# .gitignore
*.tfvars
!dev.tfvars
!prod.tfvars

# Workflow
terraform plan -var-file=dev.tfvars
```

**Pros**:
- Simple to understand and use
- Good for non-sensitive configuration
- Clear separation between environments

**Cons**:
- Not suitable for secrets or sensitive data
- All configuration is visible in the repository
- Requires updates to the repository for configuration changes

### 4. GitHub Environments with Secrets

**How it works**: Define environment-specific secrets in GitHub Environments.

```yaml
jobs:
  terraform:
    environment: dev
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set Terraform Variables
      run: |
        echo "TF_VAR_api_key=${{ secrets.API_KEY }}" >> $GITHUB_ENV
```

**Pros**:
- Secure handling of sensitive values
- Environment-specific values
- Required approvals and protections
- Integration with GitHub permissions

**Cons**:
- Limited to GitHub's secrets management
- Manual secret management in GitHub UI

## Hybrid Approach (Recommended)

The most effective approach is often a combination of these methods:

1. **Simple, non-sensitive variables**: Use `TF_VAR_` environment variables
2. **Complex data structures**: Generate a small `.tfvars` file just for these
3. **Sensitive data**: Use GitHub Secrets injected as environment variables
4. **Environment-specific settings**: Use GitHub Environments

Example:
```yaml
jobs:
  terraform:
    name: 'Terraform'
    environment: dev
    
    steps:
    # Basic variables as environment variables
    - name: Set Terraform Variables
      run: |
        echo "TF_VAR_resource_group_name=rg-${{ github.event.repository.name }}-dev" >> $GITHUB_ENV
        echo "TF_VAR_location=westeurope" >> $GITHUB_ENV
    
    # Sensitive variables from GitHub Secrets
    - name: Set Sensitive Variables
      run: |
        echo "TF_VAR_api_key=${{ secrets.API_KEY }}" >> $GITHUB_ENV
    
    # Complex variables as tfvars file
    - name: Create Complex Variables File
      run: |
        cat > complex.tfvars << 'EOF'
        tags = {
          Environment = "development"
          Project     = "${{ github.event.repository.name }}"
          ManagedBy   = "terraform"
        }
        EOF
    
    # Use both in Terraform
    - name: Terraform Plan
      run: terraform plan -var-file=complex.tfvars
```

## Security Considerations

1. **Never commit sensitive values** to your repository, even in `.tfvars` files
2. **Use GitHub Secrets** for sensitive data
3. **Consider using HashiCorp Vault** for more advanced secrets management
4. **Rotate credentials regularly**
5. **Use least-privilege service principals** for Azure authentication
6. **Audit your environment variables** to ensure sensitive data isn't logged

## GitHub Environments Best Practices

1. **Create separate environments** for dev, test, production
2. **Use environment protection rules** for production environments
3. **Set required reviewers** for deployments to sensitive environments
4. **Use different credentials** for different environments
5. **Consider deployment branches** to control which branches can deploy to which environments
