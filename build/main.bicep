param location string = resourceGroup().location
param containerAppEnvName string = 'containerAppEnvName'
param containerImageRevisionSuffix string
param server1ContainerImage string
param server2ContainerImage string
@secure()
param queueTriggerConnectionString string

// ServiceBus
resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: 'containerServiceBus2'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    zoneRedundant: false
  }
  identity: {
    type: 'SystemAssigned'
  }
  
}

resource serviceBusSendUpdateRequestTopic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  name: 'send-update-request'
  parent: serviceBus
}

// resource serviceBusSendUpdateRequestSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
//   name: 'server2'
//   parent: serviceBusSendUpdateRequestTopic
// }

// Environment
module environment 'environment.bicep' = {
  name: 'containerAppEnv2'
  params: {
    location: location
    containerAppLogAnalyticsName: 'containerAppLogAnalyticsName'
    containerAppEnvName: containerAppEnvName
    serviceBusName: serviceBus.name
  }
}

// Container apps
module server1 'containerApp.bicep' = {
  name: 'server11'
  params: {
    location: location
    environmentId: environment.outputs.containerAppEnvId
    name: 'server11'
    containerImage: server1ContainerImage
    revisionSuffix: containerImageRevisionSuffix
    ingressExternal: true
    applicationInsightsConnectionString: environment.outputs.applicationInsightsConnectionString
    tableName: 'TodoView'
  }
}

module server2 'containerApp.bicep' = {
  name: 'server22'
  params: {
    location: location
    environmentId: environment.outputs.containerAppEnvId
    name: 'server22'
    containerImage: server2ContainerImage
    revisionSuffix: containerImageRevisionSuffix
    ingressExternal: false
    applicationInsightsConnectionString: environment.outputs.applicationInsightsConnectionString
    tableName: 'Todos'
    serviceBusTriggerConnectionString: queueTriggerConnectionString
  }
}

// --
// Permissions
// --

// serviceBusSendUpdateRequestTopic
resource serviceBusSendUpdateRequestTopicSender 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, server1.name, 'serviceBusSendUpdateRequestTopic2')
  properties: {
    principalType: 'ServicePrincipal'
    // Azure Service Bus Data Sender
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
    principalId: server1.outputs.containerAppPrincipalId
  }
  scope: serviceBusSendUpdateRequestTopic
}

// resource serviceBusSendUpdateRequestTopicReceiver 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(resourceGroup().id, server2.name, 'serviceBusSendUpdateRequestTopic')
//   properties: {
//     principalType: 'ServicePrincipal'
//     // Azure Service Bus Data Receiver
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0')
//     principalId: server2.outputs.containerAppPrincipalId
//   }
//   scope: serviceBusSendUpdateRequestTopic
// }

resource serviceBusSendUpdateRequestTopicReceiverOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, server2.name, 'serviceBusSendUpdateRequestTopicOwner2')
  properties: {
    principalType: 'ServicePrincipal'
    // Azure Service Bus Data Owner
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
    principalId: server2.outputs.containerAppPrincipalId
  }
  scope: serviceBusSendUpdateRequestTopic
}

output server1FQDN string = server1.outputs.ingressFqdn
