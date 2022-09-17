param containerRegistryName string = 'containterRegistry${uniqueString(resourceGroup().id)}'
param keyVaultName string = 'keyVault${uniqueString(resourceGroup().id)}'
param appName string = 'functionApp${uniqueString(resourceGroup().id)}'
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
    appName: appName
  }
}
