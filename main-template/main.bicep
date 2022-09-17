param location string = 'Europe West'

targetScope = 'subscription'

module resourceGroupModule '../resource-group/azuredeploy.bicep' = {
  name: 'linkedDeployment'
  params: {
    name: 'compressorResourceGroup'
    location: location
  }
}
