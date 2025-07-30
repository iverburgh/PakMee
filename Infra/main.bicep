param location string = resourceGroup().location
param environment string = 'prod'
param appName string = 'pakmee'

var backendAppName = '${appName}-api'
var frontendAppName = '${appName}-web'
var sqlServerName = '${appName}sql${uniqueString(resourceGroup().id)}'
var sqlDbName = 'pakmee-db'

resource sqlServer 'Microsoft.Sql/servers@2022-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: 'sqladminuser'
    administratorLoginPassword: 'VerySecurePassword123!' // Gebruik secret!
  }
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    capacity: 1
    family: 'Gen5'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-11-01' = {
  name: '${sqlServer.name}/${sqlDbName}'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: '${appName}-asp'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  properties: {
    reserved: true
  }
}

resource backendApp 'Microsoft.Web/sites@2022-09-01' = {
  name: backendAppName
  location: location
  kind: 'app'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOTNET|8.0'
    }
  }
}

resource staticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: frontendAppName
  location: location
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    repositoryUrl: 'https://github.com/YOUR_GITHUB/pakmee'
    branch: 'main'
    buildProperties: {
      appLocation: 'client'
      outputLocation: 'dist'
      apiLocation: ''
    }
  }
}
