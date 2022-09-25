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

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = true

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. The object ID must be unique for the list of access policies. Get it by using Get-AzADUser or Get-AzADServicePrincipal cmdlets.')
param objectId string = 'fb18a347-876b-4072-a936-3dab8fcadd8b'

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'list', 'get'
]

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenantId
        permissions: {
          secrets: secretsPermissions
        }
      }
    ]
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
