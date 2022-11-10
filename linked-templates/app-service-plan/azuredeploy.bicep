param appServicePlanName string
param location string
param sku string = 'B1'

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

output serverFarmId string = appServicePlan.id
