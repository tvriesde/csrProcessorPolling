targetScope = 'resourceGroup'
var abbrs = loadJsonContent('../abbreviations.json')

param location string = 'eastus'
param environment string = 'dev'
param application string = 'csrprocessorpolling'

var systemTopicName = '${abbrs.eventGridDomainsTopics}${application}-${environment}-${location}'
var namespaceTopicName = '${abbrs.eventHubNamespacesTopic}${application}-${environment}-${location}'
var namespaceName = '${abbrs.eventHubNamespaces}${application}-ns-${environment}-${location}'

var userDefinedTopicIdentityName = '${abbrs.managedIdentityUserAssignedIdentities}${application}-${environment}-${location}-namespacetopic'


resource namespaceTopic 'Microsoft.EventGrid/namespaces/topics@2023-12-15-preview' existing = {
  name: '${namespaceName}/${namespaceTopicName}'
}

resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {
  name: '${systemTopicName}/keyvaultSubscription'
  properties: {
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    deliveryWithResourceIdentity: {
      destination: {
        endpointType: 'NamespaceTopic'
        properties: {
          resourceId: resourceId('Microsoft.EventGrid/namespaces/topics', namespaceName, namespaceTopicName)
        }
      }
      identity: {
        type: 'UserAssigned'
        userAssignedIdentity: eventGridToNamespaceTopicIdentity.id
      }
    }
  }
}

resource eventGridToNamespaceTopicIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userDefinedTopicIdentityName
  location: location
}
