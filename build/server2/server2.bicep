param location string
param logAnalyticsId string
param environmentId string
param containerImage string
param revisionSuffix string
param serviceBusName string
param serviceBusCreateTodoTopicName string

var appName = 'todoprocessing'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourceGroup().name}-ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    RetentionInDays: 30
    WorkspaceResourceId: logAnalyticsId
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'storage${uniqueString(resourceGroup().id)}'
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
    resource table 'tables@2022-09-01' = {
      name: 'table2'
    }
  }
}

var environmentVariables = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsights.properties.ConnectionString
  }
  {
    name: 'tableEndpoint'
    value: storage.properties.primaryEndpoints.table
  }
  {
    name: 'tableName'
    value: storage::table.name
  }
]

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
  resource createTodoTopic 'topics@2022-01-01-preview' existing = {
    name: serviceBusCreateTodoTopicName
    resource queueTriggerAutorization 'authorizationRules@2022-01-01-preview' = {
      name: 'QueueTriggerAccessKey'
      properties: {
        rights: [
          'Manage'
        ]
      }
    }
    resource subscription 'subscriptions@2022-01-01-preview' = {
      name: appName
    }
  }
}

var scaleTriggerTopicConnectionStringName = 'scaletrigger-topic-connectionstring'
var scaleTriggerTopicConnectionString = listKeys(
  serviceBus::createTodoTopic::queueTriggerAutorization.id, 
  serviceBus::createTodoTopic::queueTriggerAutorization.apiVersion
  ).primaryConnectionString

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }  
  properties: {
    environmentId: environmentId
    configuration: {
      ingress: {
        external: false
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      activeRevisionsMode: 'Single'
      maxInactiveRevisions: 2
      dapr: {
        enabled: true
        appId: appName
        appPort: 80
        appProtocol: 'http'
        enableApiLogging: true
        logLevel: 'info'
      }
      secrets: [
        {
          name: scaleTriggerTopicConnectionStringName
          value: scaleTriggerTopicConnectionString
        }
      ]
    }
    template: {
      revisionSuffix: revisionSuffix
      containers: [
        {
          name: appName
          image: containerImage
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
          env: environmentVariables
          probes: [
            {
              type: 'Startup'
              httpGet: {
                path: '/Readiness'
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 1
              failureThreshold: 9
              successThreshold: 1
            }
            {
              type: 'Readiness'
              httpGet: {
                path: '/Readiness'
                port: 80
              }
              initialDelaySeconds: 60
              periodSeconds: 240
              timeoutSeconds: 1
              failureThreshold: 9
              successThreshold: 1
            }
            {
              type: 'Liveness'
              httpGet: {
                path: '/health'
                port: 80
              }
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 1
              failureThreshold: 3
              successThreshold: 1
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        rules: [
          {
            name: 'azure-servicebus-topic-rule'
            custom: {
              type: 'azure-servicebus'
              metadata: {
                topicName: serviceBusCreateTodoTopicName
                subscriptionName: serviceBus::createTodoTopic::subscription.name
                namespace: '${serviceBus.name}.servicebus.windows.net'
                messageCount: '1'
              }
              auth: [
                {
                  secretRef: scaleTriggerTopicConnectionStringName
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}

var storageTableDataContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
resource tableContributer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, storage.id, storage::table.id, containerApp.id, storageTableDataContributor)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageTableDataContributor
    principalId: containerApp.identity.principalId
  }
  scope: storage
}

var serviceBusDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
resource sendCreateTodoMessage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerApp.id, serviceBus::createTodoTopic.id, serviceBusDataOwner)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: serviceBusDataOwner
    principalId: containerApp.identity.principalId
  }
  scope: serviceBus::createTodoTopic
}
