param appName string
param location string
param storageAccountType string = 'Standard_LRS'
param appInsightsLocation string

var functionAppName = appName
var hostingPlanName = appName
var applicationInsightsName = appName
var storageAccountName = 'fappstorage${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true  // true for Linux
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: true  // true for Linux
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'python|3.8'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

// resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
//   name: 'web'
//   // kind: 'string'
//   parent: functionApp
//   properties: {
//     branch: 'main'
//     deploymentRollbackEnabled: false
//     gitHubActionConfiguration: {
//     //   codeConfiguration: {
//     //     runtimeStack: 'string'
//     //     runtimeVersion: 'string'
//     //   }
//     //   containerConfiguration: {
//     //     imageName: 'string'
//     //     password: 'string'
//     //     serverUrl: 'string'
//     //     username: 'string'
//     //   }
//       generateWorkflowFile: false
//       isLinux: true
//     }
//     isGitHubAction: true
//     isManualIntegration: true
//     isMercurial: false
//     repoUrl: 'https://github.com/gontcharovd/test-function-deploy.git'
//   }
// }

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}
