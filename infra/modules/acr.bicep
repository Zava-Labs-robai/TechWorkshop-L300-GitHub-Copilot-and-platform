// Azure Container Registry Module
// Provides private container image storage for the application

@description('The name of the Azure Container Registry (must be globally unique)')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The SKU for ACR')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Enable admin user for ACR (not recommended for production)')
param adminUserEnabled bool = false

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable zone redundancy (Premium SKU only)')
param zoneRedundancy bool = false

@description('Enable public network access')
param publicNetworkAccess bool = true

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    zoneRedundancy: (sku == 'Premium') ? (zoneRedundancy ? 'Enabled' : 'Disabled') : 'Disabled'
    policies: {
      retentionPolicy: {
        status: (sku == 'Premium') ? 'enabled' : 'disabled'
        days: 30
      }
    }
  }
}

@description('The resource ID of the Container Registry')
output resourceId string = containerRegistry.id

@description('The name of the Container Registry')
output name string = containerRegistry.name

@description('The login server URL for the Container Registry')
output loginServer string = containerRegistry.properties.loginServer
