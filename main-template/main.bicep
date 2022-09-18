param containerRegistryName string = 'containterRegistry${uniqueString(resourceGroup().id)}'
param keyVaultName string = 'keyVault${uniqueString(resourceGroup().id)}'
param functionAppName string = 'functionApp${uniqueString(resourceGroup().id)}'
param webAppName string = 'webbApp${uniqueString(resourceGroup().id)}'
param postgresDatabaseName string = 'postgresdatabase${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

module containerRegistry '../linked-templates/container-registry/azuredeploy.bicep' = {
  name: 'containerRegistry'
  params:{
    containerRegistryName: containerRegistryName
    location: location
  }
}

module keyVault '../linked-templates/key-vault/azuredeploy.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: keyVaultName
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
    administratorLogin: 'gontcharovd' 
    postgresDatabaseName: postgresDatabaseName
  }
}
