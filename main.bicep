targetScope= 'subscription'

param location string
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

resource frontendResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: frontendResourceGroupName
  location: location
}

// resource backendResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
//   name: backendResourceGroupName
//   location: location
// }

// module keyVault './modules/key-vault/azuredeploy.bicep' = {
//   name: 'keyVault'
//   scope: backendResourceGroup
//   params: {
//     location: location
//     cogniteClientIDValue: cogniteClientIDValue
//     cogniteClientSecretValue: cogniteClientSecretValue
//     cogniteTenantIDValue: cogniteTenantIDValue
//     postgresUserValue: postgresUserValue
//     postgresPasswordValue: postgresPasswordValue
//   }
// }

module webApp './modules/web-app/azuredeploy.bicep' = {
  name: 'webApp'
  scope: frontendResourceGroup
  params: {
    location: location
    postgresUserValue: postgresUserValue
    postgresPasswordValue: postgresPasswordValue
  }
}

// module functionApp './modules/function-app/azuredeploy.bicep' = {
//   name: 'functionApp'
//   scope: backendResourceGroup
//   params: {
//     location: location
//     appInsightsLocation: location
//     postgresHost: postgresDatabase.outputs.postgresHost
//     keyVaultName: keyVault.outputs.keyVaultName
//   }
// }

// module postgresDatabase './modules/postgres-database/azuredeploy.bicep' = {
//   name: 'postgresDatabase'
//   scope: backendResourceGroup
//   params: {
//     location: location
//     administratorLogin: postgresUserValue
//     administratorLoginPassword: postgresPasswordValue
//   }
// }
