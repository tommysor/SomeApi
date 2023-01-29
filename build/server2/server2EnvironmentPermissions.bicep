param appName string
param appPrincipalId string
param serviceBusName string
param serviceBusCreateTodoTopicName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
  resource createTodoTopic 'topics@2022-01-01-preview' existing = {
    name: serviceBusCreateTodoTopicName
    // resource subscription 'subscriptions@2022-01-01-preview' = {
    //   name: appName
    // }
  }
}

var serviceBusDataOwner = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419')
resource sendCreateTodoMessage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBus::createTodoTopic.id, appPrincipalId, serviceBusDataOwner)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: serviceBusDataOwner
    principalId: appPrincipalId
  }
  scope: serviceBus::createTodoTopic
}
