param webAppName string
param sku string = 'F1'
param containerImage string = 'compressor'
param containerImageTag string = 'latest'
param containerRegistry string
param linuxFxVersion string = 'DOCKER|${containerRegistry}.azurecr.io/${containerImage}:${containerImageTag}'
param location string

var appServicePlanName = webAppName
var webSiteName = toLower(webAppName)

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
}
resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: false
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: linuxFxVersion
    }
  }
}
