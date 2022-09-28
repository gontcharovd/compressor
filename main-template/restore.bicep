param location string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = 'compressorManagedIdentity'
// param storageAccountName string = 'compressormi'
param currentTime string = utcNow()
param keyVaultName string

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
    environmentVariables: [
      {
        name: 'keyVaultName'
        value: keyVaultName
      }
    ]
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: currentTime
    scriptContent: '''
      az login --identity
      echo "keyVaultName: ${keyVaultName}"
      export PGPASSWORD=$(az keyvault secret show --name postgresPassword --vault-name $keyVaultName --query value)
      echo "PGPASSWORD: ${PGPASSWORD}"
      jq -n --arg var $PGPASSWORD '{ "result": $var }' | tee $AZ_SCRIPTS_OUTPUT_PATH

      echo "Downloading database dump"
      az storage blob download \
        --blob-url https://compressormi.blob.core.windows.net/postgres-database-dump/compressor-data.dump \
        --auth-mode login \
        --file ./compressor-data.dump
      echo $PWD
      ls -lh
    '''
  }
}

// output result object = restoreDatabaseDump.properties.outputs
