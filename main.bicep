targetScope='subscription'
param location string
param resourceGroupName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01'={
  name: resourceGroupName
  location: location
}

module hub 'bicep/hub.bicep' = {
  scope: rg
  name:''
  params:{
    location:''
    hubvnetName:''
    hubBastionHostName:''
    adminPwd:''
    preSharedKey:''
  }
}

module onprem 'bicep/onprem.bicep' = {
  scope: rg
  name: 'onprem'
  params: {
    location: ''
  }
  
}

module spoke 'bicep/spoke.bicep' = {
  scope: rg
  name: 'spoke'
  params: {
    location: ''
  }
  
}

module fileshare 'bicep/fileshare.bicep' = {
  scope: rg
  name: 'fileshare'
  params: {
    location: ''
  }
  
}
