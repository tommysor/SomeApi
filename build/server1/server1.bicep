param location string = resourceGroup().location
param containerAppEnvironmentName string
param containerImage string
param revisionSuffix string
param environmentRgName string
param serviceBusName string
param serviceBusCreateTodoTopicName string
param applicationInsightsConnectionString string
param daprServiceBusPubSubName string

var appName = 'todoapi'

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
    name: 'appName'
    value: appName
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
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

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: containerAppEnvironmentName
  scope: resourceGroup(environmentRgName)
}

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }  
  properties: {
    environmentId: containerAppEnvironment.id
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
}

module server1EnvironmentPermissions 'server1EnvironmentPermissions.bicep' = {
  name: 'server1EnvironmentPermissions'
  scope: resourceGroup(environmentRgName)
  params: {
    appPrincipalId: containerApp.identity.principalId
    serviceBusName: serviceBusName
    serviceBusCreateTodoTopicName: serviceBusCreateTodoTopicName
  }
}

output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
