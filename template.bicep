param vNetHubName string = 'hub-vnet'
param virtualMachines_az_dns_vm_name string = 'az-dns-vm'
param virtualMachines_az_mgmt_vm_name string = 'az-mgmt-vm'
param vNetSpokeName string = 'spoke-vnet'
param vNetOnPremName string = 'onprem-vnet'
param nicNameDns string = 'az-dns-nic'
param vmNameOnPremDns string = 'onprem-dns-vm'
param bastionHosts_hub_bastion_host_name string = 'hub-bastion-host'
param nicNameMgmt string = 'az-mgmt-nic'
param vmNameOnPremMgmt string = 'onprem-mgmt-vm'
param bastionHosts_onprem_bastion_host_name string = 'onprem-bastion-host'
param networkInterfaces_onprem_dns_nic_name string = 'onprem-dns-nic'
param networkInterfaces_onprem_mgmt_nic_name string = 'onprem-mgmt-nic'
param publicIPAddresses_hub_bastion_pip_name string = 'hub-bastion-pip'
param storageAccountName string = 'stgcstechtalkfiles'
param publicIPAddresses_spoke_bastion_pip_name string = 'spoke-bastion-pip'
param publicIPAddresses_onprem_bastion_pip_name string = 'onprem-bastion-pip'
param publicIPAddresses_hub_vpn_gateway_pip_name string = 'hub-vpn-gateway-pip'
param virtualNetworkGateways_hub_vpn_gateway_name string = 'hub-vpn-gateway'
param onprem_vpn_gateway_pip_name string = 'onprem-vpn-gateway-pip'
param vpn_gateway_name string = 'onprem-vpn-gateway'

resource publicIPAddresses_hub_bastion_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_hub_bastion_pip_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub'
    cstechtalk: 'privatelink-dns'
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
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_hub_vpn_gateway_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_hub_vpn_gateway_pip_name
  location: 'westeurope'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_onprem_bastion_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_onprem_bastion_pip_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
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
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource onprem_vpn_gateway_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: onprem_vpn_gateway_pip_name
  location: 'westeurope'
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_spoke_bastion_pip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_spoke_bastion_pip_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    cstechtalk: 'privatelink-dns'
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
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vNetOnPremName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetOnPremName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
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

resource storageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
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

resource virtualMachines_az_dns_vm_name_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: virtualMachines_az_dns_vm_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
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
          id: resourceId('Microsoft.Compute/disks', 'az-dns-osdisk')
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_az_dns_vm_name
      adminUsername: 'AzureAdmin'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicNameDns_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource virtualMachines_az_mgmt_vm_name_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: virtualMachines_az_mgmt_vm_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
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
          id: resourceId('Microsoft.Compute/disks', 'az-mgmt-osdisk')
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_az_mgmt_vm_name
      adminUsername: 'AzureAdmin'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicNameMgmt_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource vmNameOnPremDns_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmNameOnPremDns
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
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
          id: resourceId('Microsoft.Compute/disks', 'onprem-dns-osdisk')
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmNameOnPremDns
      adminUsername: 'AzureAdmin'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_onprem_dns_nic_name_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource vmNameOnPremMgmt_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmNameOnPremMgmt
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2_v3'
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
          id: resourceId('Microsoft.Compute/disks', 'onprem-mgmt-osdisk')
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmNameOnPremMgmt
      adminUsername: 'AzureAdmin'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_onprem_mgmt_nic_name_resource.id
          properties: {
            primary: false
          }
        }
      ]
    }
  }
}

resource virtualMachines_az_dns_vm_name_install_dns_az_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${virtualMachines_az_dns_vm_name_resource.name}/install-dns-az-dc'
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

resource vmNameOnPremDns_install_dns_onprem_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: '${vmNameOnPremDns_resource.name}/install-dns-onprem-dc'
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

resource nicNameDns_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicNameDns
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: nicNameDns
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetHubName_DNSSubnet.id
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

resource nicNameMgmt_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicNameMgmt
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: nicNameMgmt
        properties: {
          privateIPAddress: '10.1.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vNetSpokeName_InfrastructureSubnet.id
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

resource networkInterfaces_onprem_dns_nic_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_onprem_dns_nic_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: networkInterfaces_onprem_dns_nic_name
        properties: {
          privateIPAddress: '192.168.0.4'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: vNetOnPremName_InfrastructureSubnet.id
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

resource networkInterfaces_onprem_mgmt_nic_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_onprem_mgmt_nic_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    ipConfigurations: [
      {
        name: networkInterfaces_onprem_mgmt_nic_name
        properties: {
          privateIPAddress: '192.168.0.5'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: vNetOnPremName_InfrastructureSubnet.id
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

resource vNetHubName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetHubName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    cstechtalk: 'privatelink-dns'
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
    enableDdosProtection: false
  }
  dependsOn: []
}

resource vNetSpokeName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vNetSpokeName
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'spoke'
    cstechtalk: 'privatelink-dns'
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
            id: vNetHubName_resource.id
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

resource vNetHubName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetHubName_resource.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetOnPremName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetOnPremName_resource.name}/AzureBastionSubnet'
  properties: {
    addressPrefix: '192.168.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetHubName_DNSSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetHubName_resource.name}/DNSSubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetHubName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetHubName_resource.name}/GatewaySubnet'
  properties: {
    addressPrefix: '10.0.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetOnPremName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetOnPremName_resource.name}/GatewaySubnet'
  properties: {
    addressPrefix: '192.168.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetOnPremName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetOnPremName_resource.name}/InfrastructureSubnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vNetSpokeName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: '${vNetSpokeName_resource.name}/InfrastructureSubnet'
  properties: {
    addressPrefix: '10.1.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource storageAccountName_default 'Microsoft.Storage/storageAccounts/fileServices@2021-04-01' = {
  name: '${storageAccountName_resource.name}/default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: false
      days: 0
    }
  }
}
resource storageAccountName_default_data 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-04-01' = {
  name: '${storageAccountName_default.name}/data'
  properties: {
    accessTier: 'Premium'
    shareQuota: 1024
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccountName_resource
  ]
}

resource bastionHosts_hub_bastion_host_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionHosts_hub_bastion_host_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    dnsName: 'bst-7b917f73-c65c-4ca8-9e5e-1f548207c6a6.bastion.azure.com'
    ipConfigurations: [
      {
        name: bastionHosts_hub_bastion_host_name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_hub_bastion_pip_name_resource.id
          }
          subnet: {
            id: vNetHubName_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource bastionHosts_onprem_bastion_host_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastionHosts_onprem_bastion_host_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    dnsName: 'bst-37c5a080-3d46-4810-9269-683a2491a3b6.bastion.azure.com'
    ipConfigurations: [
      {
        name: bastionHosts_onprem_bastion_host_name
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_onprem_bastion_pip_name_resource.id
          }
          subnet: {
            id: vNetOnPremName_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource virtualNetworkGateways_hub_vpn_gateway_name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: virtualNetworkGateways_hub_vpn_gateway_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'hub-spoke'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_hub_vpn_gateway_pip_name_resource.id
          }
          subnet: {
            id: vNetHubName_GatewaySubnet.id
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
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayGeneration: 'Generation1'
  }
}

resource vpn_gateway_name_resource 'Microsoft.Network/virtualNetworkGateways@2020-11-01' = {
  name: vpn_gateway_name
  location: 'westeurope'
  tags: {
    deployment: 'bicep'
    environment: 'onprem'
    cstechtalk: 'privatelink-dns'
  }
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: 'vnetGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onprem_vpn_gateway_pip_name_resource.id
          }
          subnet: {
            id: vNetOnPremName_GatewaySubnet.id
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
          customBgpIpAddresses: []
        }
      ]
    }
    vpnGatewayGeneration: 'Generation1'
  }
}
