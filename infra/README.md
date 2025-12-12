# ZavaStorefront Azure Infrastructure

This document describes the Azure infrastructure for the ZavaStorefront application.

## Architecture Overview

The infrastructure includes the following Azure resources:

| Resource | Purpose |
|----------|---------|
| **Azure Container Registry (ACR)** | Private container image storage |
| **Azure App Service** | Linux Web App with Docker container support |
| **App Service Plan** | PremiumV3 hosting plan |
| **Application Insights** | Application monitoring and diagnostics |
| **Log Analytics Workspace** | Centralized logging and monitoring |
| **Azure OpenAI** | AI services with GPT-4.1 and Phi-4 models |
| **RBAC** | Role assignments for secure access |

## Directory Structure

```
infra/
├── main.bicep              # Main orchestration file
├── main.bicepparam         # Parameters file for dev environment
└── modules/
    ├── acr.bicep           # Azure Container Registry
    ├── appInsights.bicep   # Application Insights
    ├── appService.bicep    # App Service (Web App)
    ├── appServicePlan.bicep # App Service Plan
    ├── cognitiveServices.bicep # Azure OpenAI
    ├── logAnalytics.bicep  # Log Analytics Workspace
    └── rbac.bicep          # RBAC role assignments
```

## Prerequisites

1. **Azure CLI** installed and configured
2. **Azure Developer CLI (azd)** installed
3. **Azure subscription** with sufficient permissions
4. **GitHub repository secrets** configured (for CI/CD)

## Deployment Options

### Option 1: Azure Developer CLI (Recommended)

```bash
# Initialize azd (first time only)
azd init

# Login to Azure
azd auth login

# Provision infrastructure and deploy
azd up

# Or provision only
azd provision

# Deploy application only
azd deploy
```

### Option 2: Azure CLI with Bicep

```bash
# Login to Azure
az login

# Create deployment at subscription level
az deployment sub create \
  --location westus3 \
  --template-file infra/main.bicep \
  --parameters infra/main.bicepparam
```

### Option 3: GitHub Actions

1. Configure the following repository secrets:
   - `AZURE_CREDENTIALS` - Service principal credentials JSON
   - `AZURE_SUBSCRIPTION_ID` - Your Azure subscription ID
   - `ACR_USERNAME` - ACR admin username (optional)
   - `ACR_PASSWORD` - ACR admin password (optional)

2. Push to the `main` branch or manually trigger the workflow.

## Configuration

### Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `location` | `westus3` | Azure region |
| `environmentName` | `dev` | Environment (dev/staging/prod) |
| `baseName` | `zava` | Base name for resources |
| `dockerImageTag` | `latest` | Docker image tag |
| `enableAI` | `true` | Enable AI model deployments |

### Customizing for Different Environments

Create additional parameter files for different environments:

```bash
# Copy and modify for staging
cp infra/main.bicepparam infra/main.staging.bicepparam
# Edit the file to change environmentName = 'staging'
```

## Security Considerations

1. **No ACR Admin User**: ACR admin is disabled; authentication uses managed identity
2. **RBAC-Based Access**: App Service uses system-assigned managed identity with AcrPull role
3. **HTTPS Only**: App Service enforces HTTPS connections
4. **TLS 1.2**: Minimum TLS version set to 1.2
5. **FTPS Disabled**: FTP access is disabled for security

## Monitoring

- **Application Insights**: Automatic instrumentation via connection string
- **Log Analytics**: Centralized log collection with 30-day retention
- **Diagnostic Settings**: Configured for all resources

## Outputs

After deployment, the following outputs are available:

| Output | Description |
|--------|-------------|
| `resourceGroupName` | The created resource group name |
| `acrLoginServer` | ACR login server URL |
| `acrName` | ACR resource name |
| `appServiceHostname` | App Service default hostname |
| `appServiceUrl` | Full HTTPS URL for the application |
| `appInsightsConnectionString` | Application Insights connection string |
| `logAnalyticsWorkspaceId` | Log Analytics workspace ID |
| `aiEndpoint` | Azure OpenAI endpoint URL |

## Troubleshooting

### Common Issues

1. **ACR Pull Failure**: Ensure RBAC role assignment has propagated (may take a few minutes)
2. **Container Startup Failure**: Check App Service logs in Log Analytics
3. **AI Model Deployment Failure**: Verify region supports the requested models

### Useful Commands

```bash
# View deployment status
az deployment sub show --name main

# Check App Service logs
az webapp log tail --name zava-dev-app --resource-group zava-dev-rg

# Test ACR connectivity
az acr check-health --name <acr-name>
```

## Clean Up

To remove all deployed resources:

```bash
# Using azd
azd down

# Using Azure CLI
az group delete --name zava-dev-rg --yes
```
