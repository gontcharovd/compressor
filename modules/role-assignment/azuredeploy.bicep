param managedIdentityId string
param managedIdentityPrincipalId string
param roleDefinitionIds array
param roleAssignmentDescription string = ''


var roleAssignmentsToCreate = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(managedIdentityId, resourceGroup().id, roleDefinitionId)
  roleDefinitionId: roleDefinitionId
}]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleAssignmentToCreate in roleAssignmentsToCreate: {
  name: roleAssignmentToCreate.name
  scope: resourceGroup()
  properties: {
    description: roleAssignmentDescription
    principalId: managedIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignmentToCreate.roleDefinitionId)
    principalType: 'ServicePrincipal' // See https://docs.microsoft.com/azure/role-based-access-control/role-assignments-template#new-service-principal to understand why this property is included.
  }
}]
