param name string = 'defaultName'
param location string = 'West Europe'
targetScope = 'subscription'

resource compressorRG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
}
