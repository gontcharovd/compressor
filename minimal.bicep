param containerImage string = 'minimal-shiny-app'
param containerImageTag string = 'latest'
param location string = 'westeurope'

// define service names
var webAppName = 'webbApp${uniqueString(resourceGroup().id)}'
var webAppServicePlanName = 'webbAppServicePlan${uniqueString(resourceGroup().id)}'
var webSiteName = toLower(webAppName)
var containerRegistryName = 'containterregistry${uniqueString(resourceGroup().id)}'

// derived variables
var linuxFxVersion = 'DOCKER|${containerRegistry.name}.azurecr.io/${containerImage}:${containerImageTag}'
var registryServerUrl = '${containerRegistry.name}.azurecr.io'
var roleDefinitionID =  '7f951dda-4ed3-4680-a7ca-43fe172d538d'  // AcrPull
var roleAssignmentName= guid(roleDefinitionID, resourceGroup().id)

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource webAppServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: webAppServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'F1'
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true
    serverFarmId: webAppServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: true
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: resourceGroup()
  properties: {
    description: 'AcrPull'
    principalId: webApp.identity.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalType: 'ServicePrincipal' // See https://docs.microsoft.com/azure/role-based-access-control/role-assignments-template#new-service-principal to understand why this property is included.
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: webApp
  properties: {
    branch: 'main'
    deploymentRollbackEnabled: false
    gitHubActionConfiguration: {
      containerConfiguration: {
        imageName: containerImage
        serverUrl: registryServerUrl
        username: containerRegistry.name
        password: 'thisIsNotARealPassword'
      }
      generateWorkflowFile: true
      isLinux: true
    }
    isGitHubAction: true
    isManualIntegration: false
    repoUrl: 'https://github.com/gontcharovd/minimal-shiny-app'
  }
}
