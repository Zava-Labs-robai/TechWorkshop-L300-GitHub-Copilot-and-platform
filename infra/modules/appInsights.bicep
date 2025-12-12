// Application Insights Module
// Provides monitoring and diagnostics for the application

@description('The name of the Application Insights resource')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The resource ID of the Log Analytics workspace for data export')
param workspaceResourceId string

@description('The type of application being monitored')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Tags to apply to the resource')
param tags object = {}

@description('Disable IP masking for logs')
param disableIpMasking bool = false

@description('Disable local authentication (require Azure AD)')
param disableLocalAuth bool = false

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    WorkspaceResourceId: workspaceResourceId
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

@description('The resource ID of Application Insights')
output resourceId string = appInsights.id

@description('The name of Application Insights')
output name string = appInsights.name

@description('The instrumentation key for Application Insights')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('The connection string for Application Insights')
output connectionString string = appInsights.properties.ConnectionString

@description('The application ID for Application Insights')
output applicationId string = appInsights.properties.AppId
