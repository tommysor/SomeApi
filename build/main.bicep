param location string = resourceGroup().location
param containerAppEnvName string = 'containerAppEnvName'
param containerImageRevisionSuffix string
param server1ContainerImage string
param server2ContainerImage string

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
    revisionSuffix: containerImageRevisionSuffix
    ingressExternal: true
    applicationInsightsConnectionString: environment.outputs.applicationInsightsConnectionString
    storageQueueName: 'view-queue'
  }
}

module server2 'containerApp.bicep' = {
  name: 'server2'
  params: {
    location: location
    environmentId: environment.outputs.containerAppEnvId
    name: 'server2'
    containerImage: server2ContainerImage
    revisionSuffix: containerImageRevisionSuffix
    ingressExternal: false
    applicationInsightsConnectionString: environment.outputs.applicationInsightsConnectionString
    storageQueueName: 'update-queue'
  }
}

output server1FQDN string = server1.outputs.ingressFqdn
