@description('Name of the External Network')
param externalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Peering option list')
@allowed([
  'OptionA'
  'OptionB'
])
param peeringOption string

@description('option A properties')
param optionAProperties object

@description('option B properties')
param optionBProperties object

@description('ARM resource ID of importRoutePolicy')
param importRoutePolicyId string

@description('ARM resource ID of exportRoutePolicy')
param exportRoutePolicyId string

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-02-01-preview' existing = {
  name: l3IsolationDomainName
}

@description('Create External Network Resource')
resource externalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/externalNetworks@2023-02-01-preview' = {
  name: externalNetworkName
  parent: l3IsolationDomains
  properties: {
    peeringOption: peeringOption
    optionAProperties: optionAProperties != {} ? {
      mtu: optionAProperties.mtu != '' ? optionAProperties.mtu : null
      vlanId: optionAProperties.vlanId
      peerASN: optionAProperties.peerASN
      primaryIpv4Prefix: optionAProperties.primaryIpv4Prefix != '' ? optionAProperties.primaryIpv4Prefix : null
      primaryIpv6Prefix: optionAProperties.primaryIpv6Prefix != '' ? optionAProperties.primaryIpv6Prefix : null
      secondaryIpv4Prefix: optionAProperties.secondaryIpv4Prefix != '' ? optionAProperties.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: optionAProperties.secondaryIpv6Prefix != '' ? optionAProperties.secondaryIpv6Prefix : null
    } : null
    optionBProperties: optionBProperties != {} ? {
      importRouteTargets: optionBProperties.importRouteTargets != '' ? optionBProperties.importRouteTargets : null
      exportRouteTargets: optionBProperties.exportRouteTargets != '' ? optionBProperties.exportRouteTargets : null
    } : null
    importRoutePolicyId: importRoutePolicyId != '' ? importRoutePolicyId : null
    exportRoutePolicyId: exportRoutePolicyId != '' ? exportRoutePolicyId : null
  }
}

output resourceID string = externalNetwork.id
