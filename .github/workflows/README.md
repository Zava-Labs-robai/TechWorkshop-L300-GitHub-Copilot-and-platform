# GitHub Actions Deployment Setup

## Required Configuration

### Secrets

Create the following secret in your repository settings (**Settings > Secrets and variables > Actions > Secrets**):

| Secret | Description |
|--------|-------------|
| `AZURE_CREDENTIALS` | Service principal credentials JSON |

To create the service principal and get credentials:

```bash
az ad sp create-for-rbac --name "github-deploy-sp" \
  --role contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RESOURCE_GROUP> \
  --sdk-auth
```

Copy the entire JSON output and save it as the `AZURE_CREDENTIALS` secret.

### Variables

Create the following variables in your repository settings (**Settings > Secrets and variables > Actions > Variables**):

| Variable | Description | Example |
|----------|-------------|---------|
| `AZURE_WEBAPP_NAME` | App Service name from Bicep deployment | `zava-dev-app` |
| `ACR_NAME` | ACR name from Bicep deployment | `zavaacr<unique-suffix>` |

You can find these values in the Azure Portal or from the `azd provision` output.
