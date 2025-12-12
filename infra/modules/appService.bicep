// App Service Module
// Linux Web App with Docker container support

@description('The name of the App Service')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The resource ID of the App Service Plan')
param appServicePlanId string

@description('The Docker image to deploy (full path including registry)')
param dockerImage string = ''

@description('Application Insights connection string')
param appInsightsConnectionString string = ''

@description('Application Insights instrumentation key')
param appInsightsInstrumentationKey string = ''

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable system-assigned managed identity')
param enableManagedIdentity bool = true

@description('Additional app settings')
param appSettings array = []

var defaultAppSettings = [
  {
    name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
    value: 'false'
  }
  {
    name: 'DOCKER_ENABLE_CI'
    value: 'true'
  }
]

var monitoringSettings = empty(appInsightsConnectionString) ? [] : [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: appInsightsConnectionString
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: appInsightsInstrumentationKey
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
]

var dockerSettings = empty(dockerImage) ? [] : [
  {
    name: 'DOCKER_REGISTRY_SERVER_URL'
    value: 'https://${split(dockerImage, '/')[0]}'
  }
]

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: empty(dockerImage) ? 'DOTNETCORE|6.0' : 'DOCKER|${dockerImage}'
      alwaysOn: true
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: concat(defaultAppSettings, monitoringSettings, dockerSettings, appSettings)
      acrUseManagedIdentityCreds: true
    }
  }
}

@description('The resource ID of the App Service')
output resourceId string = appService.id

@description('The name of the App Service')
output name string = appService.name

@description('The default hostname of the App Service')
output defaultHostname string = appService.properties.defaultHostName

@description('The principal ID of the system-assigned managed identity')
output principalId string = enableManagedIdentity ? appService.identity.principalId : ''

@description('The tenant ID of the system-assigned managed identity')
output tenantId string = enableManagedIdentity ? appService.identity.tenantId : ''
