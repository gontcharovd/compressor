param webAppName string
param serverFarmId string
param containerImage string = 'minimalshiny'
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
    enabled: true
    reserved: true
    serverFarmId: serverFarmId
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      acrUseManagedIdentityCreds: true
    }
  }
}

resource ftpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: appService
  properties: {
    allow: true
  }
}

resource scmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: appService
  properties: {
    allow: true
  }
}

resource appServiceConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  kind: 'string'
  parent: appService
  properties: {
    acrUseManagedIdentityCreds: true
    alwaysOn: false
    autoHealEnabled: false
    azureStorageAccounts: {}
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    detailedErrorLoggingEnabled: false
    experiments: {
      rampUpRules: []
    }
    ftpsState: 'AllAllowed'
    functionAppScaleLimit: 0
    functionsRuntimeScaleMonitoringEnabled: false
    http20Enabled: false
    httpLoggingEnabled: true
    ipSecurityRestrictions: [
      {
        action: 'Allow'
        description: 'Allow all access'
        ipAddress: 'Any'
        name: 'Allow all'
        priority: 2147483647
      }
    ]
    keyVaultReferenceIdentity: 'SystemAssigned'
    linuxFxVersion: linuxFxVersion
    loadBalancing: 'LeastRequests'
    localMySqlEnabled: false
    logsDirectorySizeLimit: 35
    managedPipelineMode: 'Integrated'
    managedServiceIdentityId: 14896  // What is this?
    minimumElasticInstanceCount: 0
    minTlsVersion: '1.2'
    netFrameworkVersion: 'v4.0'
    numberOfWorkers: 1
    preWarmedInstanceCount: 0
    publishingUsername: '$webbapp7cwkv6diblxjy'
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2019'
    requestTracingEnabled: false
    scmIpSecurityRestrictions: [
      {
        action: 'Allow'
        description: 'Allow all access'
        ipAddress: 'Any'
        name: 'Allow all'
        priority: 2147483647
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    scmMinTlsVersion: '1.2'
    scmType: 'GitHubAction'
    use32BitWorkerProcess: true
    virtualApplications: [
      {
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
        virtualPath: '/'
      }
    ]
    vnetPrivatePortsCount: 0
    vnetRouteAllEnabled: false
    webSocketsEnabled: false
  }
}
