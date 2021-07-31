@description('description')
param location string
param storageAccounts_stgmicrohackfiles_name string = 'stgazprivatelink'


resource storageAccounts_stgmicrohackfiles_name_resource 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccounts_stgmicrohackfiles_name
  location: location
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
