param name string = 'compressor-rg-main'
param location string = 'westeurope'

targetScope = 'subscription'

module resourceGroupModule '../resource-group/azuredeploy.bicep' = {
  name: 'linkedDeployment'
  params: {
   location: location
   name: name
  }
}
