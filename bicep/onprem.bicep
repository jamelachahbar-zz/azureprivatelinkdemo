@description('description')
param location string
param onpremVnetName string = 'onprem-vnet'
param onpremDnsVmName string = 'onprem-dns-vm'
param onpremMgmtVmName string = 'onprem-mgmt-vm'
param onpremBastionHostName string = 'onprem-bastion-host'
param onpremDnsNicName string = 'onprem-dns-nic'
param onpremMgmtNicName string = 'onprem-mgmt-nic'
param onpremBastionPipName string = 'onprem-bastion-pip'


resource onpremBastionHostName_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: onpremBastionHostName
  location: location
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

resource onpremVnetName_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: onpremVnetName_resource
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '192.168.1.0/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVnetName_GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: onpremVnetName_resource
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '192.168.255.224/27'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremVnetName_InfrastructureSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: onpremVnetName_resource
  name: 'InfrastructureSubnet'
  properties: {
    addressPrefix: '192.168.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource onpremDnsNicName_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: onpremDnsNicName
  location: location
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
  location: location
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
resource onpremDnsVmName_install_dns_onprem_dc 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  parent: onpremDnsVmName_resource
  name: 'install-dns-onprem-dc'
  location: location
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
resource onpremDnsVmName_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: onpremDnsVmName
  location: location
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
  location: location
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
resource onpremBastionPipName_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: onpremBastionPipName
  location: location
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
  properties: {
    ipAddress: '20.82.52.123'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}
resource onpremVnetName_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: onpremVnetName
  location: location
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
