param location string = resourceGroup().location
param containerAppEnvName string
param server1ContainerImage string
param server1RevisionSuffix string

module environment 'environment.bicep' = {
  name: 'containerAppEnv'
  params: {
    location: location
    containerAppLogAnalyticsName: 'containerAppLogAnalyticsName'
    containerAppEnvName: containerAppEnvName
  }
}

module server1 'containerApp.bicep' = {
  name: 'server1'
  params: {
    location: location
    environmentId: environment.outputs.containerAppEnvId
    name: 'server1'
    containerImage: server1ContainerImage
    revisionSuffix: server1RevisionSuffix
  }
}

output server1FQDN string = server1.outputs.ingressFqdn
