@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network To Network Interconnect')
param networkToNetworkInterconnectName string

@description('Type of NNI used')
@allowed([
  'CE'
  'NPB'
])
param nniType string

@description('Configuration to use NNI for Infrastructure Management')
@allowed([
  'True'
  'False'
])
param isManagementType string

@description('Based on this parameter the layer2/layer3 is made as mandatory')
@allowed([
  'True'
  'False'
])
param useOptionB string

@description('Common properties for Layer2Configuration')
param layer2Configuration object

@description('Common properties for Layer3Configuration')
param layer3Configuration object

resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-02-01-preview' existing = {
  name: networkFabricName
}

resource networkToNetworkInterconnect 'Microsoft.ManagedNetworkFabric/networkFabrics/networkToNetworkInterconnects@2023-02-01-preview' = {
  name: networkToNetworkInterconnectName
  parent: networkFabrics
  properties: {
    nniType: nniType
    isManagementType: isManagementType
    useOptionB: useOptionB
    layer2Configuration: layer2Configuration
    layer3Configuration: layer3Configuration
  }
}
