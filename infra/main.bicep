// Main Bicep Template for ZavaStorefront Infrastructure
// Orchestrates all Azure resources for the application

targetScope = 'subscription'

// =============================================
// Parameters
// =============================================

@description('The location for all resources')
param location string = 'westus3'

@description('The environment name (dev, staging, prod)')
@allowed([
  'dev'
  'staging'
  'prod'
])
param environmentName string = 'dev'

@description('Base name for resources')
param baseName string = 'zava'

@description('The Docker image tag to deploy')
param dockerImageTag string = 'latest'

@description('Enable AI model deployments')
param enableAI bool = true

// =============================================
// Variables
// =============================================

var resourceGroupName = '${baseName}-${environmentName}-rg'
var uniqueSuffix = uniqueString(subscription().subscriptionId, resourceGroupName)
var acrName = '${baseName}acr${uniqueSuffix}'
var appServicePlanName = '${baseName}-${environmentName}-plan'
var appServiceName = '${baseName}-${environmentName}-app'
var logAnalyticsName = '${baseName}-${environmentName}-logs'
var appInsightsName = '${baseName}-${environmentName}-insights'
var cognitiveServicesName = '${baseName}-${environmentName}-ai'

var tags = {
  Environment: environmentName
  Project: 'ZavaStorefront'
  ManagedBy: 'Bicep'
}

// =============================================
// Resource Group
// =============================================

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// =============================================
// Monitoring Resources
// =============================================

module logAnalytics 'modules/logAnalytics.bicep' = {
  scope: rg
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
    retentionInDays: 30
  }
}

module appInsights 'modules/appInsights.bicep' = {
  scope: rg
  params: {
    name: appInsightsName
    location: location
    tags: tags
    workspaceResourceId: logAnalytics.outputs.resourceId
  }
}

// =============================================
// Container Registry
// =============================================

module acr 'modules/acr.bicep' = {
  scope: rg
  params: {
    name: acrName
    location: location
    tags: tags
    sku: 'Standard'
    adminUserEnabled: false
  }
}

// =============================================
// App Service
// =============================================

module appServicePlan 'modules/appServicePlan.bicep' = {
  scope: rg
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    sku: {
      name: 'P1v3'
      tier: 'PremiumV3'
      capacity: 1
    }
  }
}

module appService 'modules/appService.bicep' = {
  scope: rg
  params: {
    name: appServiceName
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.resourceId
    dockerImage: '${acr.outputs.loginServer}/zavastorefont:${dockerImageTag}'
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    enableManagedIdentity: true
  }
}

// =============================================
// RBAC - ACR Pull for App Service
// =============================================

module acrPullRole 'modules/rbac.bicep' = {
  scope: rg
  params: {
    principalId: appService.outputs.principalId
    acrResourceId: acr.outputs.resourceId
    principalType: 'ServicePrincipal'
  }
}

// =============================================
// AI Services (Optional)
// =============================================

module cognitiveServices 'modules/cognitiveServices.bicep' = if (enableAI) {
  scope: rg
  params: {
    name: cognitiveServicesName
    location: location
    tags: tags
    kind: 'OpenAI'
    customSubDomainName: '${baseName}-${environmentName}-ai-${uniqueSuffix}'
    deployments: [
      {
        name: 'gpt-4-1'
        modelName: 'gpt-4.1'
        modelVersion: '2025-04-14'
        skuName: 'Standard'
        capacity: 10
      }
      {
        name: 'gpt-4-1-mini'
        modelName: 'gpt-4.1-mini'
        modelVersion: '2025-04-14'
        skuName: 'Standard'
        capacity: 10
      }
    ]
  }
}

// =============================================
// Outputs
// =============================================

// AZD required outputs - these help azd discover the deployed resources
@description('The Azure resource group name')
output AZURE_RESOURCE_GROUP string = rg.name

@description('The name of the resource group')
output resourceGroupName string = rg.name

@description('The login server for ACR')
output acrLoginServer string = acr.outputs.loginServer

@description('The ACR name')
output acrName string = acr.outputs.name

@description('The App Service name - used by azd for deployment')
output SERVICE_WEB_NAME string = appService.outputs.name

@description('The App Service default hostname')
output appServiceHostname string = appService.outputs.defaultHostname

@description('The App Service URL')
output appServiceUrl string = 'https://${appService.outputs.defaultHostname}'

@description('The web service endpoint URL - used by azd')
output SERVICE_WEB_ENDPOINT_URL string = 'https://${appService.outputs.defaultHostname}'

@description('The Application Insights connection string')
output appInsightsConnectionString string = appInsights.outputs.connectionString

@description('The Log Analytics workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.outputs.logAnalyticsWorkspaceId

@description('The Cognitive Services endpoint')
output aiEndpoint string = cognitiveServices.?outputs.?endpoint ?? 'AI services not enabled'
