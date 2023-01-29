param appPrincipalId string
param serviceBusName string
param serviceBusCreateTodoTopicName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = {
  name: serviceBusName
  resource createTodoTopic 'topics@2022-01-01-preview' existing = {
    name: serviceBusCreateTodoTopicName
  }
}

var serviceBusDataSender = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39')
resource sendCreateTodoMessage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(serviceBus::createTodoTopic.id, appPrincipalId, serviceBusDataSender)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: serviceBusDataSender
    principalId: appPrincipalId
  }
  scope: serviceBus::createTodoTopic
}
