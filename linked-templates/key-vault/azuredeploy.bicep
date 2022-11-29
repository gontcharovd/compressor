param location string
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

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

var keyVaultName = 'keyVault${uniqueString(resourceGroup().id)}'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource cogniteClientID 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogniteClientID'
  properties: {
    value: cogniteClientIDValue
  }
}

resource cogniteClientSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogniteClientSecret'
  properties: {
    value: cogniteClientSecretValue
  }
}

resource cogniteTenantID 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogniteTenantID'
  properties: {
    value: cogniteTenantIDValue
  }
}

resource postgresUser 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'postgresUser'
  properties: {
    value: postgresUserValue
  }
}

resource postgresPassword 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'postgresPassword'
  properties: {
    value: postgresPasswordValue
  }
}

output keyVaultName string = keyVault.name
