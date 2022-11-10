param webAppName string
param serverFarmId string
param containerImage string = 'compressor'
param containerImageTag string = 'latest'
param containerRegistry string
param linuxFxVersion string = 'DOCKER|${containerRegistry}.azurecr.io/${containerImage}:${containerImageTag}'
param location string

var webSiteName = toLower(webAppName)

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: false
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}
