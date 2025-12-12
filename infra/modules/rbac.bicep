// RBAC Role Assignment Module
// Assigns AcrPull role to App Service managed identity for ACR access

@description('The principal ID of the managed identity')
param principalId string

@description('The resource ID of the Azure Container Registry')
param acrResourceId string

@description('The type of principal')
@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'

// Built-in role definition IDs
// https://learn.microsoft.com/azure/role-based-access-control/built-in-roles
var acrPullRoleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrResourceId, principalId, acrPullRoleId)
  scope: acr
  properties: {
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleId)
    principalType: principalType
  }
}

// Reference the existing ACR resource
resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: last(split(acrResourceId, '/'))
}

@description('The resource ID of the role assignment')
output roleAssignmentId string = acrPullRoleAssignment.id
