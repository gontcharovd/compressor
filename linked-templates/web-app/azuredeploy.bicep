param sku string = 'F1'
param containerImage string = 'compressor'
param containerImageTag string = 'latest'
param containerRegistry string
param linuxFxVersion string = 'DOCKER|${containerRegistry}.azurecr.io/${containerImage}:${containerImageTag}'
param location string

// var registryServerUrl = '${containerRegistry}.azurecr.io'
var webAppName = 'webbApp${uniqueString(resourceGroup().id)}'
var webAppServicePlanName = 'webbAppServicePlan${uniqueString(resourceGroup().id)}'
var webSiteName = toLower(webAppName)

resource webAppServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: webAppServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
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
    enabled: true
    reserved: true
    serverFarmId: webAppServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: true
    }
  }
}

// resource ftpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
//   name: 'ftp'
//   kind: 'string'
//   parent: webApp
//   properties: {
//     allow: true
//   }
// }

// resource scmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
//   name: 'scm'
//   kind: 'string'
//   parent: webApp
//   properties: {
//     allow: true
//   }
// }

// resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
//   name: 'web'
//   parent: webApp
//   properties: {
//     branch: 'main'
//     deploymentRollbackEnabled: false
//     gitHubActionConfiguration: {
//       containerConfiguration: {
//         imageName: containerImage
//         serverUrl: registryServerUrl
//       }
//       generateWorkflowFile: true
//       isLinux: true
//     }
//     isGitHubAction: true
//     isManualIntegration: false
//     repoUrl: 'https://github.com/gontcharovd/minimal-shiny-app'
//   }
// }

// module webAppRA '../role-assignment/azuredeploy.bicep' = {
//   name: 'webApp'
//   params: {
//     managedIdentityId: webApp.identity.tenantId 
//     managedIdentityPrincipalId: webApp.identity.principalId
//     roleDefinitionIds: [
//       '7f951dda-4ed3-4680-a7ca-43fe172d538d'  // AcrPull
//     ]  
//   }
// }
