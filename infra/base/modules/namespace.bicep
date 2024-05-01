param location string
param tags object
param namespaceSku int
param privateEndpointName string
param privateEndpointSubnet string
param privateDnsZoneId string
param name string
param namespaceTopicName string

resource namespace 'Microsoft.EventGrid/namespaces@2023-12-15-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    capacity: namespaceSku
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    isZoneRedundant: true
    publicNetworkAccess: 'Disabled'
  }
}

resource topic 'Microsoft.EventGrid/namespaces/topics@2023-12-15-preview' = {
  name: namespaceTopicName
  parent: namespace
  properties: {
    eventRetentionInDays: 1
    inputSchema: 'CloudEventSchemaV1_0'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet:{
      id: privateEndpointSubnet
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: namespace.id
          groupIds: [
            'topic'
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
        name: 'config_namespace'
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
