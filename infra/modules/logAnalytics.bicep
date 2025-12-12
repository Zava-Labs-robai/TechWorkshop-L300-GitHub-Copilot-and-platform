// Log Analytics Workspace Module
// Required dependency for Application Insights

@description('The name of the Log Analytics workspace')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The retention period for data in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('The SKU for Log Analytics')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerGB2018'

@description('Tags to apply to the resource')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    workspaceCapping: {
      dailyQuotaGb: -1 // No cap
    }
  }
}

@description('The resource ID of the Log Analytics workspace')
output resourceId string = logAnalyticsWorkspace.id

@description('The name of the Log Analytics workspace')
output name string = logAnalyticsWorkspace.name

@description('The Log Analytics workspace ID (for Application Insights)')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.properties.customerId
