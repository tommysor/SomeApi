param location string
param environmentId string
param name string
param containerImage string
param revisionSuffix string

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: name
  location: location
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
        enabled: false
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
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
        rules: [
          {
            name: 'http-requests'
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
