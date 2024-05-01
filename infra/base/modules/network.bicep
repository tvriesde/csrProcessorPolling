param name string
param privateDnsZoneName string
param tags object
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.10.0/26'
        }
      }
      {
        name: 'privateEndpointsSubnet'
        properties: {
          addressPrefix: '10.0.20.0/26'
        }
      }
      {
        name: 'functionsAppSubnet'
        properties:{
          addressPrefix: '10.0.30.0/26'
        }
      }

    ]
  }
  resource subnetDefault 'subnets' existing = {
  name: 'default'
  }
  resource subnetBastion 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }
  resource subnetPrivateEndpoints 'subnets' existing = {
    name: 'privateEndpointsSubnet'
  }}


resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

output privateDnsZoneId string = privateDnsZone.id
output subnetPrivateEndpointsId string = vnet::subnetPrivateEndpoints.id
output defaultSubnetId string = vnet::subnetDefault.id
output bastionSubnetId string = vnet::subnetBastion.id
