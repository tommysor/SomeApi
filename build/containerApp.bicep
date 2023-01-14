param location string
param environmentId string
param name string
param containerImage string
param revisionSuffix string
param ingressExternal bool
param applicationInsightsConnectionString string

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
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsightsConnectionString
            }
          ]
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

output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
