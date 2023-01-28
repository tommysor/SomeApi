param location string
param environmentId string
param containerImage string
param revisionSuffix string
param environmentRgName string
param serviceBusName string
param serviceBusCreateTodoTopicName string
param logAnalyticsId string
param daprServiceBusPubSubName string

var appName = 'todoapi'

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
      name: 'todos'
    }
  }
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
  scope: resourceGroup(environmentRgName)
  resource createTodoTopic 'topics@2022-01-01-preview' existing = {
    name: serviceBusCreateTodoTopicName
  }
}

var createTodoPublishUrl = 'http://localhost:3500/v1.0/publish/${daprServiceBusPubSubName}/${serviceBus::createTodoTopic.name}'

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
  {
    name: 'createTodoPublishUrl'
    value: createTodoPublishUrl
  }
]

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
        external: true
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

var serviceBusDataSender = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
resource sendCreateTodoMessage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerApp.id, serviceBus::createTodoTopic.id, serviceBusDataSender)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: serviceBusDataSender
    principalId: containerApp.identity.principalId
  }
  scope: serviceBus::createTodoTopic
}

output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
