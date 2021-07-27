param hubvnetName string = 'hub-vnet'
param azDnsVmName string = 'az-dns-vm'
param azMgmtVmName string = 'az-mgmt-vm'
param spokeVnetName string = 'spoke-vnet'
param hub_onprem_connectionName string = 'hub-onprem-conn'
param onprem_hub_connectionName string = 'onprem-hub-conn'
param onpremVnetName string = 'onprem-vnet'
param azDnsNicName string = 'az-dns-nic'
param onpremDnsVmName string = 'onprem-dns-vm'
param hubBastionHostName string = 'hub-bastion-host'
param azMgmtNicName string = 'az-mgmt-nic'
param onpremMgmtVmName string = 'onprem-mgmt-vm'
param onpremBastionHostName string = 'onprem-bastion-host'
param onpremDnsNicName string = 'onprem-dns-nic'
param onpremMgmtNicName string = 'onprem-mgmt-nic'
param hubBastionPipName string = 'hub-bastion-pip'
param storageAccounts_stgmicrohackfiles_name string = 'stgazprivatelink'
param onpremBastionPipName string = 'onprem-bastion-pip'
param hubVpnGatewayPipName string = 'hub-vpn-gateway-pip'
param hubVpnGatewayName string = 'hub-vpn-gateway'
param onpremVpnGatewayPipName string = 'onprem-vpn-gateway-pip'
param onpremVpnGatewayName string = 'onprem-vpn-gateway'

@description('description')
@secure()
param adminPwd string

@description('description')
@secure()
param preSharedKey string

resource hubBastionPipName_resource 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: hubBastionPipName
  location: 'westeurope'
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

resource hubVpnGatewayPipName_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: hubVpnGatewayPipName
  location: 'westeurope'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource onpremBastionPipName_resource 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: onpremBastionPipName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
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
}

resource onpremVpnGatewayPipName_resource 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: onpremVpnGatewayPipName
  location: 'westeurope'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource onpremVnetName_resource 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: onpremVnetName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    microhack: 'privatelink-dns'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '192.168.0.4'
      ]
    }
    subnets: [
      {
        name: 'InfrastructureSubnet'
        properties: {
          addressPrefix: '192.168.0.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '192.168.255.224/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '192.168.1.0/27'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource storageAccounts_stgmicrohackfiles_name_resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccounts_stgmicrohackfiles_name
  location: 'westeurope'
  sku: {
    name: 'Premium_LRS'
    tier: 'Premium'
  }
  kind: 'FileStorage'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        table: {
          keyType: 'Account'
          enabled: true
        }
        queue: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource azDnsVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: azDnsVmName
  location: 'westeurope'
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

resource azMgmtVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: azMgmtVmName
  location: 'westeurope'
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

resource onpremDnsVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: onpremDnsVmName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
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
        name: 'onprem-dns-osdisk'
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
      computerName: onpremDnsVmName
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
          id: onpremDnsNicName_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource onpremMgmtVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: onpremMgmtVmName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
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
        name: 'onprem-mgmt-osdisk'
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
      computerName: onpremMgmtVmName
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
          id: onpremMgmtNicName_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource azDnsVmName_install_dns_az_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${azDnsVmName_resource.name}/install-dns-az-dc'
  location: 'westeurope'
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

resource onpremDnsVmName_install_dns_onprem_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${onpremDnsVmName_resource.name}/install-dns-onprem-dc'
  location: 'westeurope'
  properties: {
    autoUpgradeMinorVersion: false
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.9'
    settings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted Install-WindowsFeature -Name DNS -IncludeAllSubFeature -IncludeManagementTools; Add-DnsServerForwarder -IPAddress 8.8.8.8 -PassThru; exit 0'
    }
    protectedSettings: {}
  }
}

resource azDnsNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: azDnsNicName
  location: 'westeurope'
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
  location: 'westeurope'
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

resource onpremDnsNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: onpremDnsNicName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    microhack: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: onpremDnsNicName
        properties: {
          privateIPAddress: '192.168.0.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: onpremVnetName_InfrastructureSubnet.id
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

resource onpremMgmtNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: onpremMgmtNicName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    microhack: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: onpremMgmtNicName
        properties: {
          privateIPAddress: '192.168.0.5'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: onpremVnetName_InfrastructureSubnet.id
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

resource hubvnetName_resource 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: hubvnetName
  location: 'westeurope'
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

resource spokeVnetName_resource 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: spokeVnetName
  location: 'westeurope'
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

resource hubvnetName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${hubvnetName_resource.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVnetName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${onpremVnetName_resource.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '192.168.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubvnetName_DNSSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${hubvnetName_resource.name}/DNSSubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubvnetName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${hubvnetName_resource.name}/GatewaySubnet'
  properties: {
    addressPrefix: '10.0.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVnetName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${onpremVnetName_resource.name}/GatewaySubnet'
  properties: {
    addressPrefix: '192.168.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVnetName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${onpremVnetName_resource.name}/InfrastructureSubnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource spokeVnetName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: '${spokeVnetName_resource.name}/InfrastructureSubnet'
  properties: {
    addressPrefix: '10.1.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubvnetName_PrivateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${hubvnetName_resource.name}/PrivateEndpointSubnet'
  properties: {
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource hubBastionHostName_resource 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: hubBastionHostName
  location: 'westeurope'
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

resource onpremBastionHostName_resource 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: onpremBastionHostName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    microhack: 'privatelink-dns'
  }
  sku: {
    name: 'Basic'
  }
  properties: {
    ipConfigurations: [
      {
        name: onpremBastionHostName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onpremBastionPipName_resource.id
          }
          subnet: {
            id: onpremVnetName_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource hub_onprem_connectionName_resource 'Microsoft.Network/connections@2020-06-01' = {
  name: hub_onprem_connectionName
  location: 'westeurope'
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

resource onprem_hub_connectionName_resource 'Microsoft.Network/connections@2020-06-01' = {
  name: onprem_hub_connectionName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    microhack: 'privatelink-dns'
  }
  properties: {
    virtualNetworkGateway1: {
      id: hubVpnGatewayName_resource.id
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

resource hubVpnGatewayName_resource 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: hubVpnGatewayName
  location: 'westeurope'
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

resource onpremVpnGatewayName_resource 'Microsoft.Network/virtualNetworkGateways@2020-06-01' = {
  name: onpremVpnGatewayName
  location: 'westeurope'
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

resource hubvnetName_hub_spoke_peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${hubvnetName_resource.name}/hub-spoke-peer'
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

resource spokeVnetName_spoke_hub_peer 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-06-01' = {
  name: '${spokeVnetName_resource.name}/spoke-hub-peer'
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
  dependsOn: [
    hubVpnGatewayName_resource
  ]
}

resource storageAccounts_stgmicrohackfiles_name_default_data 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccounts_stgmicrohackfiles_name}/default/data'
  properties: {
    accessTier: 'Premium'
    shareQuota: 1024
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccounts_stgmicrohackfiles_name_resource
  ]
}
