param location string
param postgresDatabaseName string
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = 'compressorManagedIdentity'
param currentTime string = utcNow()

@secure()
param administratorLogin string
@secure()
param administratorLoginPassword string

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: postgresDatabaseName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    version: '13'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    network: {
      delegatedSubnetResourceId: (empty(virtualNetworkExternalId) ? json('null') : json('${virtualNetworkExternalId}/subnets/${subnetName}'))
      privateDnsZoneArmResourceId: (empty(virtualNetworkExternalId) ? json('null') : privateDnsZoneArmResourceId)
    }
    highAvailability: {
      mode: 'Disabled'
    }
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    availabilityZone: '1'
  }
}

resource allowAzureResourcesRule 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2022-01-20-preview' = {
  name: 'AllowAllAzureServicesAndResources'
  parent: postgresDatabase
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: 'compressor-managed-identity'
  scope: resourceGroup(subscriptionId, resourceGroupName)
}

resource seedPostgresDatabase 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
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
        name: 'administratorLogin'
        value: postgresDatabase.properties.administratorLogin
      }
      {
        name: 'PGPASSWORD'
        value: administratorLoginPassword
      }
      {
        name: 'postgresDatabaseName'
        value: postgresDatabase.name
      }
    ]
    cleanupPreference: 'OnSuccess'
    forceUpdateTag: currentTime
    scriptContent: '''
      az login --identity

      apk add --no-cache postgresql-client 

      psql \
        --host=${postgresDatabaseName}.postgres.database.azure.com \
        --username=$administratorLogin \
        --dbname=postgres <<-EOSQL
          CREATE TABLE IF NOT EXISTS public.pressure (
            timestamp TIMESTAMPTZ NOT NULL,
            asset_id BIGINT NOT NULL,
            sensor_name VARCHAR (25) NOT NULL,
            pressure REAL,
            PRIMARY KEY (timestamp, asset_id)
        );
      EOSQL
    '''
  }
}
