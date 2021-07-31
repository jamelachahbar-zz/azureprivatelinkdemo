param location string
param spokeVnetName string = 'spoke-vnet'

resource spokeVnetName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: spokeVnetName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: 'InfrastructureSubnet'
        properties: {
          addressPrefix: '10.1.0.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.1.1.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'spoke-hub-peer'
        properties: {
          peeringState: 'Connected'
          remoteVirtualNetwork: {
            id: hubvnetName_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: false
          useRemoteGateways: true
          remoteAddressSpace: {
            addressPrefixes: [
              '10.0.0.0/16'
            ]
          }
        }
      }
    ]
    enableDdosProtection: false
  }
}
resource spokeVnetName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: spokeVnetName_resource
  name: 'InfrastructureSubnet'
  properties: {
    addressPrefix: '10.1.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}
resource spokeVnetName_spoke_hub_peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: spokeVnetName_resource
  name: 'spoke-hub-peer'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: hubvnetName_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
    remoteAddressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}
