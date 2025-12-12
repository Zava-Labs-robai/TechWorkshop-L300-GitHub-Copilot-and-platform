// Cognitive Services Module
// Azure AI Services with GPT-4.1 and Phi-4 model deployments

@description('The name of the Cognitive Services account')
param name string

@description('Location for the resource')
param location string = resourceGroup().location

@description('The kind of Cognitive Services account')
@allowed([
  'AIServices'
  'OpenAI'
])
param kind string = 'OpenAI'

@description('The SKU for Cognitive Services')
param sku string = 'S0'

@description('Custom subdomain name for the account (required for model deployments)')
param customSubDomainName string

@description('Tags to apply to the resource')
param tags object = {}

@description('Enable public network access')
param publicNetworkAccess bool = true

@description('Model deployments configuration')
param deployments array = []

resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    name: sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    customSubDomainName: customSubDomainName
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAcls: {
      defaultAction: publicNetworkAccess ? 'Allow' : 'Deny'
    }
    disableLocalAuth: false
  }
}

// Deploy AI models
@batchSize(1)
resource modelDeployments 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [for deployment in deployments: {
  parent: cognitiveServices
  name: deployment.name
  sku: {
    name: deployment.?skuName ?? 'Standard'
    capacity: deployment.?capacity ?? 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: deployment.modelName
      version: deployment.?modelVersion ?? ''
    }
    raiPolicyName: deployment.?raiPolicyName ?? null
  }
}]

@description('The resource ID of the Cognitive Services account')
output resourceId string = cognitiveServices.id

@description('The name of the Cognitive Services account')
output name string = cognitiveServices.name

@description('The endpoint URL for the Cognitive Services account')
output endpoint string = cognitiveServices.properties.endpoint

@description('The principal ID of the system-assigned managed identity')
output principalId string = cognitiveServices.identity.principalId
