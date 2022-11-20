param webAppName string
param serverFarmId string
param containerImage string = 'compressor'
param containerImageTag string = 'latest'
param containerRegistry string
param linuxFxVersion string = 'DOCKER|${containerRegistry}.azurecr.io/${containerImage}:${containerImageTag}'
param location string

var registryServerUrl = '${containerRegistry}.azurecr.io'
var webSiteName = toLower(webAppName)

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
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
      alwaysOn: false
      autoHealEnabled: false
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
      loadBalancing: 'LeastRequests'
      localMySqlEnabled: false
      logsDirectorySizeLimit: 35
      managedPipelineMode: 'Integrated'
      managedServiceIdentityId: 14896  // What is this?
      minTlsVersion: '1.2'
      netFrameworkVersion: 'v4.0'
      numberOfWorkers: 1
      preWarmedInstanceCount: 0
      publishingUsername: webAppName  // used to be '$webbapp7cwkv6diblxjy'
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
}

resource ftpPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'ftp'
  kind: 'string'
  parent: webApp
  properties: {
    allow: true
  }
}

resource scmPolicy 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  name: 'scm'
  kind: 'string'
  parent: webApp
  properties: {
    allow: true
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = {
  name: 'web'
  parent: webApp
  properties: {
    branch: 'main'
    deploymentRollbackEnabled: false
    gitHubActionConfiguration: {
      containerConfiguration: {
        imageName: containerImage
        serverUrl: registryServerUrl
      }
      generateWorkflowFile: true
      isLinux: true
    }
    isGitHubAction: true
    isManualIntegration: true
    repoUrl: 'https://github.com/gontcharovd/compressor-shiny-app'
  }
}

module webAppRA '../role-assignment/azuredeploy.bicep' = {
  name: 'webApp'
  params: {
    managedIdentityId: webApp.identity.tenantId 
    managedIdentityPrincipalId: webApp.identity.principalId
    roleDefinitionIds: [
      '7f951dda-4ed3-4680-a7ca-43fe172d538d'  // AcrPull
    ]  
  }
}
