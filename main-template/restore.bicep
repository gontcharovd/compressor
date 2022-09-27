param location string = resourceGroup().location
param subscriptionId string = subscription().id
param resourceGroup string = 'compressorManagedIdentity'
param keyVaultName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'compressor-managed-identity'
}

// https://www.youtube.com/watch?v=c4hTBTWyA_w
resource restoreDatabaseDump 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'restoreDatabaseDump'
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.37.0'
    retentionInterval: 'P1D'
    arguments: '-keyVaultName ${keyVaultName}'
    scriptContent: '''
      #param([string] $keyVaultName)
      #export PGPASSWORD=$(az keyvault secret show --name postgresPassword --vault-name $keyVaultName --query value)
      echo $keyVaultName
    '''
  }
}
