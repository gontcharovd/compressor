param keyVaultName string
param location string
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

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

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

resource cogniteApiKey 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogniteApiKey'
  properties: {
    value: cogniteApiKeyValue
  }
}

resource cogniteProject 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogiteProject'
  properties: {
    value: cogniteProjectValue
  }
}

resource cogniteClient 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'cogniteClient'
  properties: {
    value: cogniteClientValue
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
