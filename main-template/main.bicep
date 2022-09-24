param containerRegistryName string = 'containterRegistry${uniqueString(resourceGroup().id)}'
param functionAppName string = 'functionApp${uniqueString(resourceGroup().id)}'
param webAppName string = 'webbApp${uniqueString(resourceGroup().id)}'
@description('Postgres database name must be lowercase.')
param postgresDatabaseName string = 'postgresdatabase${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param keyVaultName string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

module containerRegistry '../linked-templates/container-registry/azuredeploy.bicep' = {
  name: 'containerRegistry'
  params:{
    containerRegistryName: containerRegistryName
    location: location
  }
}

module functionApp '../linked-templates/function-app/azuredeploy.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    appInsightsLocation: location
    appName: functionAppName
  }
}

module webApp '../linked-templates/web-app/azuredeploy.bicep' = {
  name: 'webApp'
  params: {
    webAppName: webAppName
    location: location
    containerRegistry: containerRegistryName
  }
}

module postgresDatabase '../linked-templates/postgres-database/azuredeploy.bicep' = {
  name: 'postgresDatabase'
  params: {
    location: location 
    administratorLogin: keyVault.getSecret('postgresUser')
    administratorLoginPassword: keyVault.getSecret('postgresPassword')
    postgresDatabaseName: postgresDatabaseName
  }
}
