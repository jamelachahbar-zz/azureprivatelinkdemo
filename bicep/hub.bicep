@description('description')
param location string
param hub_onprem_connectionName string = 'hub-onprem-conn'
param onprem_hub_connectionName string = 'onprem-hub-conn'
param hubVpnGatewayPipName string = 'hub-vpn-gateway-pip'
param hubVpnGatewayName string = 'hub-vpn-gateway'
param onpremVpnGatewayPipName string = 'onprem-vpn-gateway-pip'
param hubvnetName string = 'hub-vnet'
param hubBastionHostName string = 'hub-bastion-host'
param hubBastionPipName string = 'hub-bastion-pip'
param onpremVpnGatewayName string = 'onprem-vpn-gateway'
param azDnsNicName string = 'az-dns-nic'
param azMgmtNicName string = 'az-mgmt-nic'
param azDnsVmName string = 'az-dns-vm'
param azMgmtVmName string = 'az-mgmt-vm'
@description('description')
@secure()
param preSharedKey string

@description('description')
@secure()
param adminPwd string


resource hubBastionPipName_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: hubBastionPipName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub'
    microhack: 'privatelink-dns'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    ipAddress: '20.82.54.94'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}
resource azDnsVmName_install_dns_az_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: azDnsVmName_resource
  name: 'install-dns-az-dc'
  location: location
  properties: {
    autoUpgradeMinorVersion: false
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted Install-WindowsFeature -Name DNS -IncludeAllSubFeature -IncludeManagementTools; exit 0'
    }
    protectedSettings: {}
  }
}
resource azDnsNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: azDnsNicName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: azDnsNicName
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubvnetName_DNSSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}
resource azMgmtNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: azMgmtNicName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: azMgmtNicName
        properties: {
          privateIPAddress: '10.1.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: spokeVnetName_InfrastructureSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}
resource azMgmtVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: azMgmtVmName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS3_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'az-mgmt-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: azMgmtVmName
      adminUsername: 'azureadmin'
      adminPassword: adminPwd
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: azMgmtNicName_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}
resource azDnsVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: azDnsVmName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_DS3_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'az-dns-osdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: azDnsVmName
      adminUsername: 'azureadmin'
      adminPassword: adminPwd
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: azDnsNicName_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}
resource hub_onprem_connectionName_resource 'Microsoft.Network/connections@2020-11-01' = {
  name: hub_onprem_connectionName
  location: location
  properties: {
    virtualNetworkGateway1: {
      id: hubVpnGatewayName_resource.id
    }
    virtualNetworkGateway2: {
      id: onpremVpnGatewayName_resource.id
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    routingWeight: 1
    enableBgp: false
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: []
    trafficSelectorPolicies: []
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0
    connectionMode: 'Default'
    sharedKey: preSharedKey
  }
}

resource onprem_hub_connectionName_resource 'Microsoft.Network/connections@2020-11-01' = {
  name: onprem_hub_connectionName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    virtualNetworkGateway1: {
      id: onpremVpnGatewayName_resource.id
    }
    virtualNetworkGateway2: {
      id: hubVpnGatewayName_resource.id
    }
    connectionType: 'Vnet2Vnet'
    connectionProtocol: 'IKEv2'
    routingWeight: 1
    enableBgp: false
    useLocalAzureIpAddress: false
    usePolicyBasedTrafficSelectors: false
    ipsecPolicies: []
    trafficSelectorPolicies: []
    expressRouteGatewayBypass: false
    dpdTimeoutSeconds: 0
    connectionMode: 'Default'
    sharedKey: preSharedKey
  }
}
resource hubVpnGatewayPipName_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: hubVpnGatewayPipName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.93.153.49'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource onpremVpnGatewayName_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: onpremVpnGatewayName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    microhack: 'privatelink-dns'
  }
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onpremVpnGatewayPipName_resource.id
          }
          subnet: {
            id: onpremVnetName_GatewaySubnet.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnClientConfiguration: {
      vpnClientProtocols: [
        'OpenVPN'
        'IkeV2'
      ]
      vpnClientRootCertificates: []
      vpnClientRevokedCertificates: []
      radiusServers: []
      vpnClientIpsecPolicies: []
    }
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '192.168.255.254'
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: '${onpremVpnGatewayName_resource.id}/ipConfigurations/vnetGatewayConfig'
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayGeneration: 'Generation1'
  }
}


resource hubvnetName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: hubvnetName_resource
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVpnGatewayPipName_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: onpremVpnGatewayPipName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.86.163.117'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}


resource hubvnetName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: hubvnetName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.255.224/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'DNSSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.1.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'PrivateEndpointSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: [
      {
        name: 'hub-spoke-peer'
        properties: {
          peeringState: 'Connected'
          remoteVirtualNetwork: {
            id: spokeVnetName_resource.id
          }
          allowVirtualNetworkAccess: true
          allowForwardedTraffic: true
          allowGatewayTransit: true
          useRemoteGateways: false
          remoteAddressSpace: {
            addressPrefixes: [
              '10.1.0.0/16'
            ]
          }
        }
      }
    ]
    enableDdosProtection: false
  }
  dependsOn: []
}
resource hubvnetName_DNSSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: hubvnetName_resource
  name: 'DNSSubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubvnetName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: hubvnetName_resource
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '10.0.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}


resource hubvnetName_PrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: hubvnetName_resource
  name: 'PrivateEndpointSubnet'
  properties: {
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubBastionHostName_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: hubBastionHostName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub'
    microhack: 'privatelink-dns'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: hubBastionHostName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: hubBastionPipName_resource.id
          }
          subnet: {
            id: hubvnetName_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}


resource hubVpnGatewayName_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: hubVpnGatewayName
  location: location
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: hubVpnGatewayPipName_resource.id
          }
          subnet: {
            id: hubvnetName_GatewaySubnet.id
          }
        }
      }
    ]
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnClientConfiguration: {
      vpnClientProtocols: [
        'OpenVPN'
        'IkeV2'
      ]
      vpnClientRootCertificates: []
      vpnClientRevokedCertificates: []
      radiusServers: []
      vpnClientIpsecPolicies: []
    }
    bgpSettings: {
      asn: 65515
      bgpPeeringAddress: '10.0.255.254'
      peerWeight: 0
      bgpPeeringAddresses: [
        {
          ipconfigurationId: '${hubVpnGatewayName_resource.id}/ipConfigurations/vnetGatewayConfig'
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayGeneration: 'Generation1'
  }
}

resource hubvnetName_hub_spoke_peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: hubvnetName_resource
  name: 'hub-spoke-peer'
  properties: {
    peeringState: 'Connected'
    remoteVirtualNetwork: {
      id: spokeVnetName_resource.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteAddressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}
