param appName string
param location string
param storageAccountType string = 'Standard_LRS'
param appInsightsLocation string
param postgresHost string
param keyVaultName string

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
        {
          name: 'HOST_NAME'
          value: postgresHost
        }
        {
          name: 'VAULT_NAME'
          value: keyVaultName
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  kind: 'GitHubAction'
  parent: functionApp
  properties: {
    branch: 'main'
    deploymentRollbackEnabled: false
    gitHubActionConfiguration: {
      codeConfiguration: {
        runtimeStack: 'python'
        runtimeVersion: '3.8'
      }
      generateWorkflowFile: false
      isLinux: true
    }
    isGitHubAction: true
    isManualIntegration: false
    isMercurial: false
    repoUrl: 'https://github.com/gontcharovd/get-sensor-data.git'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

module functionAppRA '../role-assignment/azuredeploy.bicep' = {
  name: 'runctionAppRA'
  params: {
    managedIdentityId: functionApp.identity.tenantId 
    managedIdentityPrincipalId: functionApp.identity.principalId
    roleDefinitionIds: [
      '4633458b-17de-408a-b874-0445c86b69e6'  // key vault secrets user
      '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'  // SQL DB Contributor
    ]  
  }
}
