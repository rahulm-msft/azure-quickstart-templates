@description('Name of Internal Network')
param internalNetworkName string

@description('Name of the L3 Isolation Domain')
param l3IsolationDomainName string

@description('Vlan identifier value')
@minValue(100)
@maxValue(4095)
param vlanId int

@description('Maximum transmission unit')
param mtu int = 0

@description('List with object connected IPv4 Subnets')
param connectedIPv4Subnets array = []

@description('List with object connected IPv6 Subnets')
param connectedIPv6Subnets array = []

@description('Static Route Configuration model')
param staticRouteConfiguration object = {}

@description('BGP configuration properties')
param bgpConfiguration object = {}

@description('ARM resource ID of Import Route Policy')
param importRoutePolicyId string = ''

@description('ARM resource ID of Export Route Policy')
param exportRoutePolicyId string = ''

@description('Name of existing l3 Isolation Domain Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-02-01-preview' existing = {
  name: l3IsolationDomainName
}

@description('Create Internal Network Resource')
resource internalNetwork 'Microsoft.ManagedNetworkFabric/l3IsolationDomains/internalNetworks@2023-02-01-preview' = {
  name: internalNetworkName
  parent: l3IsolationDomains
  properties: {
    vlanId: vlanId
    mtu: mtu != 0 ? mtu : null
    connectedIPv4Subnets: connectedIPv4Subnets != [] ? connectedIPv4Subnets : null
    connectedIPv6Subnets: connectedIPv6Subnets != [] ? connectedIPv6Subnets : null
    staticRouteConfiguration: staticRouteConfiguration != {} ? {
      ipv4Routes: (contains(staticRouteConfiguration, 'ipv4Routes') && staticRouteConfiguration.ipv4Routes != []) ? staticRouteConfiguration.ipv4Routes : null
      ipv6Routes: (contains(staticRouteConfiguration, 'ipv6Routes')  && staticRouteConfiguration.ipv6Routes != []) ? staticRouteConfiguration.ipv6Routes : null
    } : null
    bgpConfiguration: bgpConfiguration != {} ? {
      defaultRouteOriginate: contains(bgpConfiguration, 'defaultRouteOriginate') ? bgpConfiguration.defaultRouteOriginate : null
      allowAS: bgpConfiguration.allowAS
      allowASOverride: bgpConfiguration.allowASOverride
      peerASN: bgpConfiguration.peerASN
      ipv4ListenRangePrefixes: contains(bgpConfiguration, 'ipv4ListenRangePrefixes') ? bgpConfiguration.ipv4ListenRangePrefixes : null
      ipv6ListenRangePrefixes: contains(bgpConfiguration, 'ipv6ListenRangePrefixes') ? bgpConfiguration.ipv6ListenRangePrefixes : null
      ipv4NeighborAddress: contains(bgpConfiguration, 'ipv4NeighborAddress') ? bgpConfiguration.ipv4NeighborAddress : null
      ipv6NeighborAddress: contains(bgpConfiguration, 'ipv6NeighborAddress') ? bgpConfiguration.ipv6NeighborAddress : null
    } : null
    importRoutePolicyId: importRoutePolicyId != '' ? importRoutePolicyId : null
    exportRoutePolicyId: exportRoutePolicyId != '' ? exportRoutePolicyId : null
  }
}

output resourceID string = internalNetwork.id
