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

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'containerServiceBus'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    zoneRedundant: false
  }
  identity: {
    type: 'SystemAssigned'
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
  resource serviceBusPubSub 'daprComponents@2022-06-01-preview' = {
    name: 'servicebus-pub-sub'
    properties: {
      componentType: 'pubsub.azure.servicebus'
      version: 'v1'
      metadata: [
        {
          name: 'namespaceName'
          value: serviceBus.name
        }
      ]
    }
  }
}

output containerAppEnvId string = containerAppEnv.id
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
