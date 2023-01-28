param location string = resourceGroup().location

var rgUniqueString = uniqueString(resourceGroup().id)

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: 'logWs${rgUniqueString}'
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
  name: 'ai${rgUniqueString}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: logAnalytics.id
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'sb${rgUniqueString}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    zoneRedundant: false
  }
  identity: {
    type: 'SystemAssigned'
  }
  resource createTodoTopic 'topics@2022-01-01-preview' = {
    name: 'create-todo'
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: 'appEnv${rgUniqueString}'
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
          value: '${serviceBus.name}.servicebus.windows.net'
        }
      ]
    }
  }
}

output containerAppEnvironmentId string = containerAppEnv.id
output logAnalyticsId string = logAnalytics.id
output serviceBusName string = serviceBus.name
output serviceBusCreateTodoTopicName string = serviceBus::createTodoTopic.name
