param keyVaultName string
@description('Postgres database name must be lowercase.')
param location string = resourceGroup().location

// secrets
@secure()
param cogniteApiKeyValue string
@secure()
param cogniteProjectValue string
@secure()
param cogniteClientValue string
@secure()
param postgresUserValue string
@secure()
param postgresPasswordValue string

module keyVault '../key-vault/azuredeploy.bicep' = {
  name: 'keyVault'
  params: {
    location: location
    keyVaultName: keyVaultName
    cogniteApiKeyValue: cogniteApiKeyValue
    cogniteClientValue: cogniteClientValue
    cogniteProjectValue: cogniteProjectValue
    postgresUserValue: postgresUserValue
    postgresPasswordValue: postgresPasswordValue
  }
}
