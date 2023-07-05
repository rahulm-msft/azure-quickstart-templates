@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network To Network Interconnect')
param networkToNetworkInterconnectName string

@description('Type of NNI used')
@allowed([
  'CE'
  'NPB'
])
param nniType string = 'CE'

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
param layer2Configuration object = {}

@description('Common properties for Layer3Configuration')
param layer3Configuration object = {}

@description('Existing Network Fabric')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-02-01-preview' existing = {
  name: networkFabricName
}

@description('Create Network To Network Interconnect Resource')
resource networkToNetworkInterconnect 'Microsoft.ManagedNetworkFabric/networkFabrics/networkToNetworkInterconnects@2023-02-01-preview' = {
  name: networkToNetworkInterconnectName
  parent: networkFabrics
  properties: {
    nniType: nniType
    isManagementType: isManagementType
    useOptionB: useOptionB
    layer2Configuration: layer2Configuration != {} ? {
      portCount: contains(layer2Configuration, 'portCount') ? layer2Configuration.portCount : null
      mtu: layer2Configuration.mtu
    } : null
    layer3Configuration: layer2Configuration != {} ? {
      vlanId: contains(layer3Configuration, 'vlanId') ? layer3Configuration.vlanId : null
      peerASN: contains(layer3Configuration, 'peerASN') ? layer3Configuration.peerASN : null
      importRoutePolicyId: contains(layer3Configuration, 'importRoutePolicyId') ? layer3Configuration.importRoutePolicyId : null
      exportRoutePolicyId: contains(layer3Configuration, 'exportRoutePolicyId') ? layer3Configuration.exportRoutePolicyId : null
      primaryIpv4Prefix: contains(layer3Configuration, 'primaryIpv4Prefix') ? layer3Configuration.primaryIpv4Prefix : null
      primaryIpv6Prefix: contains(layer3Configuration, 'primaryIpv6Prefix') ? layer3Configuration.primaryIpv6Prefix : null
      secondaryIpv4Prefix: contains(layer3Configuration, 'secondaryIpv4Prefix') ? layer3Configuration.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: contains(layer3Configuration, 'secondaryIpv6Prefix') ? layer3Configuration.secondaryIpv6Prefix : null
    } : null
  }
}
