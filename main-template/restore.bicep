param location string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = 'compressorManagedIdentity'
param storageAccountName string = 'compressormi'
param containerName string = 'postgres-database-dump'
param dataDumpName string = 'compressor-data.dump'
param currentTime string = utcNow()
param keyVaultName string

var storageURL = environment().suffixes.storage

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
      {
        name: 'storageAccountName'
        value: storageAccountName
      }
      {
        name: 'containerName'
        value: containerName
      }
      {
        name: 'dataDumpName'
        value: dataDumpName
      }
      {
        name: 'storageURL'
        value: storageURL
      }
    ]
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: currentTime
    scriptContent: '''
      az login --identity

      echo "Getting Postgres password from Key Vault"
      export PGPASSWORD=$(az keyvault secret show --name postgresPassword --vault-name $keyVaultName --query value | xargs)

      echo "Downloading Postgres database dump"
      url=https://${storageAccountName}.blob.${storageURL}/${containerName}/${dataDumpName}
      az storage blob download \
        --blob-url $url \
        --auth-mode login \
        --file ./${dataDumpName}

      echo "Installing postgresql-client"
      apk add --no-cache postgresql-client 

      echo "Seeding database"
      pg_restore \
        --host=postgresdatabase7cwkv6diblxjy.postgres.database.azure.com \
        --dbname=postgres \
        --username=gontcharovd \
        --verbose \
        ./${dataDumpName}
    '''
  }
}
