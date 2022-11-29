param location string = resourceGroup().location
param frontendResourceGroupName string
param backendResourceGroupName string

@secure()
param cogniteClientIDValue string
@secure()
param cogniteClientSecretValue string
@secure()
param cogniteTenantIDValue string
@secure()
param postgresUserValue string
@secure()
param postgresPasswordValue string

var webAppName = 'webbApp${uniqueString(frontendResourceGroupName)}'
var containerRegistryName = 'containterregistry${uniqueString(frontendResourceGroupName)}'
var keyVaultName = 'keyVault${uniqueString(resourceGroup().id)}'
var functionAppName = 'functionApp${uniqueString(resourceGroup().id)}'
@description('Postgres database name must be lowercase.')
var postgresDatabaseName = 'postgresdatabase${uniqueString(resourceGroup().id)}'

var subscriptionID = subscription().id

module backendResourceGroup './linked-templates/resource-group/azuredeploy.bicep' = {
  name: 'backendResourceGroup'
  scope: subscription(subscriptionID)
  params: {
    resourceGroupName: backendResourceGroupName
    location: location
  }
}

module frontendResourceGroup './linked-templates/resource-group/azuredeploy.bicep' = {
  name: 'frontendResourceGroup'
  scope: subscription(subscriptionID)
  params: {
    resourceGroupName: backendResourceGroupName
    location: location
  }
}

module keyVault './linked-templates/key-vault/azuredeploy.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: keyVaultName
    cogniteClientIDValue: cogniteClientIDValue
    cogniteClientSecretValue: cogniteClientSecretValue
    cogniteTenantIDValue: cogniteTenantIDValue
    postgresUserValue: postgresUserValue
    postgresPasswordValue: postgresPasswordValue
  }
}

module containerRegistry './linked-templates/container-registry/azuredeploy.bicep' = {
  name: 'containerRegistry'
  scope: resourceGroup(frontendResourceGroup.name)
  params: {
    containerRegistryName: containerRegistryName
    location: location
  }
}

module webApp './linked-templates/web-app/azuredeploy.bicep' = {
  name: 'webApp'
  scope: resourceGroup(frontendResourceGroup.name)
  params: {
    webAppName: webAppName
    location: location
    containerRegistry: containerRegistry.outputs.registryName
  }
}

module functionApp './linked-templates/function-app/azuredeploy.bicep' = {
  name: 'functionApp'
  scope: resourceGroup(backendResourceGroup.name)
  params: {
    location: location
    appInsightsLocation: location
    appName: functionAppName
    postgresHost: postgresDatabase.outputs.postgresHost
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module postgresDatabase './linked-templates/postgres-database/azuredeploy.bicep' = {
  name: 'postgresDatabase'
  scope: resourceGroup(backendResourceGroup.name)
  params: {
    location: location
    administratorLogin: postgresUserValue
    administratorLoginPassword: postgresPasswordValue
    postgresDatabaseName: postgresDatabaseName
  }
}
