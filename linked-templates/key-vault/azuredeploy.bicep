param keyVaultName string
param location string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name:  'standard'
    }
    tenantId: 'd940f32d-5061-4e88-8b6c-297e55a8d555'
    accessPolicies: [
      {
        tenantId: 'd940f32d-5061-4e88-8b6c-297e55a8d555'
        objectId: '79ee31fa-ccb8-419d-b512-829cb5008cfd'
        permissions: {
          keys: []
          secrets: ['list', 'get']
          certificates: []
        }
      }
    ]
  }
}
