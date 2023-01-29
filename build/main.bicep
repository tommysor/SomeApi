targetScope = 'subscription'

param location string = 'norwayeast'
param environmentRgName string
param apiRgName string
param processingRgName string
param containerImageRevisionSuffix string
param server1ContainerImage string
param server2ContainerImage string

module resourceGroups 'environment/resourceGroups.bicep' = {
  name: 'resourceGroups'
  params: {
    location: location
    environmentRgName: environmentRgName
    apiRgName: apiRgName
    processingRgName: processingRgName
  }
}

module environment 'environment/environment.bicep' = {
  name: 'environment'
  scope: resourceGroup(environmentRgName)
  dependsOn: [
    resourceGroups
  ]
  params: {
    location: location
  }
}

module server1 'server1/server1.bicep' = {
  name: 'server1'
  scope: resourceGroup(apiRgName)
  params: {
    location: location
    environmentRgName: environmentRgName
    logAnalyticsId: environment.outputs.logAnalyticsId
    environmentId: environment.outputs.containerAppEnvironmentId
    containerImage: server1ContainerImage
    revisionSuffix: containerImageRevisionSuffix
    serviceBusName: environment.outputs.serviceBusName
    serviceBusCreateTodoTopicName: environment.outputs.serviceBusCreateTodoTopicName
    daprServiceBusPubSubName: environment.outputs.daprServiceBusPubSubName
  }
}

module server2 'server2/server2.bicep' = {
  name: 'server2'
  scope: resourceGroup(processingRgName)
  params: {
    location: location
    environmentRgName: environmentRgName
    logAnalyticsId: environment.outputs.logAnalyticsId
    environmentId: environment.outputs.containerAppEnvironmentId
    containerImage: server2ContainerImage
    revisionSuffix: containerImageRevisionSuffix
    serviceBusName: environment.outputs.serviceBusName
    serviceBusCreateTodoTopicName: environment.outputs.serviceBusCreateTodoTopicName
    serviceBusCreateTodoTopicQueueTriggerAutorizationName: environment.outputs.serviceBusCreateTodoTopicQueueTriggerAutorizationName
  }
}

output server1FQDN string = server1.outputs.ingressFqdn
