// App Service Plan Module
// Provides the hosting environment for the Linux App Service

@description('The name of the App Service Plan')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The SKU for App Service Plan')
param sku object = {
  name: 'P1v3'
  tier: 'PremiumV3'
  capacity: 1
}

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable zone redundancy')
param zoneRedundant bool = false

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
    zoneRedundant: zoneRedundant
  }
  sku: sku
}

@description('The resource ID of the App Service Plan')
output resourceId string = appServicePlan.id

@description('The name of the App Service Plan')
output name string = appServicePlan.name
