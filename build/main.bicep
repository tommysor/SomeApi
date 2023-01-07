param location string = 'norwayeast'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: 'containerAppLogAnalyticsName'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: 'containerAppEnvName'
  location: location
  
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

// resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
//   name: containerAppName
//   location: location
//   properties: {
//     managedEnvironmentId: containerAppEnv.id
//     configuration: {
//       ingress: {
//         external: true
//         targetPort: 80
//         allowInsecure: false
//         traffic: [
//           {
//             latestRevision: true
//             weight: 100
//           }
//         ]
//       }
//     }
//     template: {
//       revisionSuffix: 'firstrevision'
//       containers: [
//         {
//           name: containerAppName
//           image: frontendContainerImage
//           env: [
//             {
//               name: 'REDIS'
//               value: 'localhost'
//             }
//           ]
//           resources: {
//             cpu: json('.25')
//             memory: '.5Gi'
//           }
//         }
//         {
//           name: 'redis'
//           image: backendContainerImage
//           env: [
//             {
//               name: 'ALLOW_EMPTY_PASSWORD'
//               value: 'yes'
//             }
//           ]
//           resources: {
//             cpu: json('.25')
//             memory: '.5Gi'
//           }
//         }
//       ]
//       scale: {
//         minReplicas: 0
//         maxReplicas: 1
//         rules: [
//           {
//             name: 'http-requests'
//             http: {
//               metadata: {
//                 concurrentRequests: '10'
//               }
//             }
//           }
//         ]
//       }
//     }
//   }
// }

// output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn
