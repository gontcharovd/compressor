// code 
param location string = 'westeurope'

resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: 'myPostgresDatabase'
  location: location
}
