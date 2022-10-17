param location string
param postgresDatabaseName string
param managedIdentityName string
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''
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

resource postgresDeploymentScriptMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

module postgresDeploymentScriptRA '../role-assignment/azuredeploy.bicep' = {
  name: 'postgresDeploymentScriptRA'
  params:{
    managedIdentityId: postgresDeploymentScriptMI.id
    managedIdentityPrincipalId: postgresDeploymentScriptMI.properties.principalId
    roleDefinitionIds: [
      'acdd72a7-3385-48ef-bd42-f606fba81ae7'  // Reader
      '9b7fa17d-e63e-47b0-bb0a-15c516ac86ec'  // SQL DB Contributor
    ]
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

resource createPostgresTable 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createPostgresTable'
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${postgresDeploymentScriptMI.id}': {}
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
