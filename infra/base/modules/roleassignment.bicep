param principalIdFunctionApp string
//param principalIdEventGridSubscription string 
param roleDefinitionIdKeyVault string
//param roleDefinitionEventGridSubscription string
param keyVaultName string
//param eventGridTopicName string

param namespaceName string
param namespaceTopicName string 
param userDefinedTopicIdentity string
param roleDefinitionEventGridContributorId string
param eventGridToNamespaceTopicPrincipalId string 

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

// Create the role assignments
resource roleAssignmentKeyVault 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: kv
  name: guid(kv.id, principalIdFunctionApp, roleDefinitionIdKeyVault)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionIdKeyVault)
    principalId: principalIdFunctionApp
  }
}


resource roleAssignmentSubscriptionToNamespace 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: namespaceTopic
  name: guid(userDefinedTopicIdentity, namespaceTopic.id, roleDefinitionEventGridContributorId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionEventGridContributorId)
    principalId: eventGridToNamespaceTopicPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource namespaceTopic 'Microsoft.EventGrid/namespaces/topics@2023-12-15-preview' existing = {
  name: '${namespaceName}/${namespaceTopicName}'
}
