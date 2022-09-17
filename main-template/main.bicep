param location string = 'Europe West'
param resourceGroupName string

targetScope = 'subscription'

module resourceGroupModule '../resource-group/azuredeploy.bicep' = {
  name: 'linkedDeployment'
  params: {
    name: resourceGroupName
    location: location
  }
}
