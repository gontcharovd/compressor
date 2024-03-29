param location string
param storageAccountType string = 'Standard_LRS'
param appInsightsLocation string
param postgresHost string
param keyVaultName string

var appName = 'functionApp${uniqueString(resourceGroup().id)}'
var functionAppName = appName
var hostingPlanName = 'functionAppServicePlan${uniqueString(resourceGroup().id)}'
var applicationInsightsName = 'funtionAppInsights${uniqueString(resourceGroup().id)}'
var storageAccountName = 'fappstorage${uniqueString(resourceGroup().id)}'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'Storage'
}

resource functionAppHostingPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
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
    serverFarmId: functionAppHostingPlan.id
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
  parent: functionApp
  properties: {
    branch: 'main'
    deploymentRollbackEnabled: false
    gitHubActionConfiguration: {
      codeConfiguration: {
        runtimeStack: 'python'
        runtimeVersion: '3.8'
      }
      generateWorkflowFile: true
      isLinux: true
    }
    isGitHubAction: true
    isManualIntegration: false
    repoUrl: 'https://github.com/gontcharovd/get-sensor-data'
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
  name: 'functionAppRA'
  params: {
    managedIdentityId: functionApp.identity.tenantId 
    managedIdentityPrincipalId: functionApp.identity.principalId
    roleDefinitionIds: [
      '4633458b-17de-408a-b874-0445c86b69e6'  // key vault secrets user
      '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'  // SQL DB Contributor
    ]  
  }
}
