param containerRegistryName string = 'containterregistry${uniqueString(resourceGroup().id)}'
param functionAppName string = 'functionApp${uniqueString(resourceGroup().id)}'
param webAppName string = 'webbApp${uniqueString(resourceGroup().id)}'
@description('Postgres database name must be lowercase.')
param postgresDatabaseName string = 'postgresdatabase${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param keyVaultName string = 'keyVault${uniqueString(resourceGroup().id)}'

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
  params: {
    containerRegistryName: containerRegistryName
    location: location
  }
}

module functionApp './linked-templates/function-app/azuredeploy.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    appInsightsLocation: location
    appName: functionAppName
    postgresHost: postgresDatabase.outputs.postgresHost
    keyVaultName: keyVault.outputs.keyVaultName
  }
}

module webApp './linked-templates/web-app/azuredeploy.bicep' = {
  name: 'webApp'
  params: {
    webAppName: webAppName
    location: location
    containerRegistry: containerRegistry.outputs.registryName
  }
}

module postgresDatabase './linked-templates/postgres-database/azuredeploy.bicep' = {
  name: 'postgresDatabase'
  params: {
    location: location
    administratorLogin: postgresUserValue
    administratorLoginPassword: postgresPasswordValue
    postgresDatabaseName: postgresDatabaseName
  }
}
