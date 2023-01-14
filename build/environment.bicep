param location string
param containerAppLogAnalyticsName string
param containerAppEnvName string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: containerAppLogAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
      dailyQuotaGb: 1
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'containerApplicationInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: logAnalytics.id
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: containerAppEnvName
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
    daprAIConnectionString: applicationInsights.properties.ConnectionString
  }
}

resource storage1 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'storage1${guid(resourceGroup().id)}' 
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  resource table 'tableServices@2022-09-01' = {
    name: 'default'
  }
  resource queue 'queueServices@2022-09-01' = {
    name: 'default'
    resource viewQueue 'queues@2022-09-01' = {
      name: 'viewQueue'
    }
  }
}

resource storage2 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'storage2${guid(resourceGroup().id)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
  resource table 'tableServices@2022-09-01' = {
    name: 'default'
  }
  resource queue 'queueServices@2022-09-01' = {
    name: 'default'
    resource updateQueue 'queues@2022-09-01' = {
      name: 'updateQueue'
    }
  }
}

output containerAppEnvId string = containerAppEnv.id
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString

output storage1ConnectionString string = storage1.properties.primaryEndpoints.table
output storage1QueueConnectionString string = storage1.properties.primaryEndpoints.queue

output storage2ConnectionString string = storage2.properties.primaryEndpoints.table
output storage2QueueConnectionString string = storage2.properties.primaryEndpoints.queue
