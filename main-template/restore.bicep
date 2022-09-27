param location string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = 'compressorManagedIdentity'
param storageAccountName string = 'compressormi'
param currentTime string = utcNow()
// param keyVaultName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'compressor-managed-identity'
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

resource restoreDatabaseDump 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'restoreDatabaseDump'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    azCliVersion: '2.37.0'
    retentionInterval: 'P1D'
    arguments: '-storageAccountName ${storageAccountName}'
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: currentTime
    scriptContent: '''
      az login --identity
      #export PGPASSWORD=$(az keyvault secret show --name postgresPassword --vault-name $keyVaultName --query value)
      blob_name=$(az storage blob list --container-name postgres-database-dump --account-name $storageAccountName --query [0].name)
      echo '{"result":' '"'$blob_name'"}' > $AZ_SCRIPTS_OUTPUT_PATH
    '''
  }
}
