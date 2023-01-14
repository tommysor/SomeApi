param location string
param environmentId string
param name string
param containerImage string
param revisionSuffix string
param ingressExternal bool
param applicationInsightsConnectionString string
param storageQueueName string
param tableName string

@description('Array of objects with properties name and value')
param environmentVariables array = []

var environmentVariablesInternal = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
  }
]

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${name}${uniqueString(guid(resourceGroup().id))}'
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
      name: tableName
    }
  }
  resource queue 'queueServices@2022-09-01' = {
    name: 'default'
    resource queue 'queues@2022-09-01' = {
      name: storageQueueName
    }
  }
}

var environmentVariablesStore = [
  {
    name: 'tableEndpoint'
    value: storage.properties.primaryEndpoints.table
  }
  {
    name: 'tableName'
    value: tableName
  }
  {
    name: 'queueEndpoint'
    value: storage.properties.primaryEndpoints.queue
  }
]

var environmentVariablesUnion = union(environmentVariablesInternal, environmentVariablesStore, environmentVariables)

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }  
  properties: {
    environmentId: environmentId
    configuration: {
      ingress: {
        external: ingressExternal
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
        appId: name
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
          name: name
          image: containerImage
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
          env: environmentVariablesUnion
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

resource tableContributer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerApp.id, 'tablestorage')
  properties: {
    principalType: 'ServicePrincipal'
    // Storage Table Data Contributor
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: containerApp.identity.principalId
  }
  scope: storage
}

resource queueContributer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, containerApp.id, 'tablestorage')
  properties: {
    principalType: 'ServicePrincipal'
    // Storage Queue Data Contributor
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalId: containerApp.identity.principalId
  }
  scope: storage
}

output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
