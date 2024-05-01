param name string
param tags object
param location string
param privateDnsZoneId string
param subnetId string
param privateEndpointName string
param topicName string
param eventGridToNamespaceTopicIdentityName string 

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    enableRbacAuthorization: true
    sku: {
      name: 'standard' 
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet:{
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: kv.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

resource keyVaultTopic 'Microsoft.EventGrid/SystemTopics@2023-12-15-preview' = {
  name: topicName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  identity:{
    type: 'UserAssigned'
      userAssignedIdentities: {
        '${eventGridToNamespaceTopicIdentity.id}' : {}
    }
  }

  properties:{
    source: kv.id
    topicType: 'Microsoft.KeyVault.vaults'
  }
}
resource eventGridToNamespaceTopicIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: eventGridToNamespaceTopicIdentityName
  location: location
}

output eventGridToNamespaceTopicIdentityPrincipal string = eventGridToNamespaceTopicIdentity.properties.principalId
output systemTopicName string = keyVaultTopic.name
