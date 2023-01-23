param location string = 'westeurope'
param postgresName string = 'postgres'
param postgresHost string = 'postgrespostgres7cwkv6diblxjy.postgres.database.azure.com'
param postgresPort string = '5432'
@secure()
param postgresUserValue string
@secure()
param postgresPasswordValue string

// define unique service names
var webAppName = 'webbApp${uniqueString(resourceGroup().id)}'
var webAppServicePlanName = 'webbAppServicePlan${uniqueString(resourceGroup().id)}'
var webSiteName = toLower(webAppName)
var containerRegistryName = 'containterregistry${uniqueString(resourceGroup().id)}'

// variables
var containerImage = 'compressor/dashboard'
var linuxFxVersion = 'DOCKER|${buildContainerImage.outputs.acrImage}'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource webAppServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: webAppServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: 'B1'
  }
  kind: 'linux'
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webSiteName
  location: location
  properties: {
    reserved: true
    serverFarmId: webAppServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      ftpsState: 'FtpsOnly'
      http20Enabled: true
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistry.name}.azurecr.io'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: containerRegistry.name
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: listCredentials(containerRegistry.id, containerRegistry.apiVersion).passwords[0].value
        }
        {
          name: 'WEBSITES_PORT'
          value: '8501'
        }
        {
          name: 'DB_USER'
          value: postgresUserValue
        }
        {
          name: 'DB_PWD'
          value: postgresPasswordValue
        }
        {
          name: 'DB_PORT'
          value: postgresPort
        }
        {
          name: 'DB_HOST'
          value: postgresHost
        }
        {
          name: 'DB_NAME'
          value: postgresName
        }
      ]
    }
  }
}

module buildContainerImage 'br/public:deployment-scripts/build-acr:1.0.1' = {
  name: 'buildContainerImage'
  params: {
    AcrName: containerRegistry.name
    location: location
    gitRepositoryUrl: 'https://github.com/gontcharovd/minimal-shiny-app.git'
    gitRepoDirectory: '.'
    imageName: containerImage
  }
}
