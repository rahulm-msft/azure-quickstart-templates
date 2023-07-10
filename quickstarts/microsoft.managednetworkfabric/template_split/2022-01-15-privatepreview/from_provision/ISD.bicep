@description('Name of L3 domain')
param l3DomainName string

@description('List of L3 domain')
param ISDList object

@description('Array Index value')
param index int

@description('NetworkFabric Id')
param fabricId string

var value = [for item in items(ISDList): item.value]

var internalNetworkCount = length(value[index].internalNetwork)
var externalNetworkCount = length(value[index].externalNetwork)

resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2022-01-15-privatepreview' = {
  name: l3DomainName
  location: resourceGroup().location
  properties: {
    networkFabricId: fabricId
    internal: {
      importRoutePolicyIds: value[index].properties.internal.importRoutePolicyIds != [] ? value[index].properties.internal.importRoutePolicyIds : null
      exportRoutePolicyIds: value[index].properties.internal.exportRoutePolicyIds != [] ? value[index].properties.internal.exportRoutePolicyIds : null
    }
    external: {
      importRoutePolicyIds: value[index].properties.external.importRoutePolicyIds != [] ? value[index].properties.external.importRoutePolicyIds : null
      exportRoutePolicyIds: value[index].properties.external.exportRoutePolicyIds != [] ? value[index].properties.external.exportRoutePolicyIds : null
      optionBConfiguration: value[index].properties.external.optionBConfiguration
    }
  }
  resource internalNetwork 'internalNetworks' = [for i in range(0, internalNetworkCount): {
    name: value[index].internalNetwork[i].name
    properties: {
      vlanId: value[index].internalNetwork[i].properties.vlanId
      mtu: value[index].internalNetwork[i].properties.mtu
      connectedIPv4Subnets: value[index].internalNetwork[i].properties.connectedIPv4Subnets != [] ? value[index].internalNetwork[i].properties.connectedIPv4Subnets : null
      connectedIPv6Subnets: value[index].internalNetwork[i].properties.connectedIPv6Subnets != [] ? value[index].internalNetwork[i].properties.connectedIPv6Subnets : null
      staticRouteConfiguration: {
        ipv4Routes: value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes != [] ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes : null
        ipv6Routes: value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes != [] ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes : null
      }
      bgpConfiguration: {
        defaultRouteOriginate: value[index].internalNetwork[i].properties.bgpConfiguration.defaultRouteOriginate
        fabricASN: value[index].internalNetwork[i].properties.bgpConfiguration.fabricASN
        peerASN: value[index].internalNetwork[i].properties.bgpConfiguration.peerASN
        ipv4Prefix: value[index].internalNetwork[i].properties.bgpConfiguration.ipv4Prefix != '' ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4Prefix : null
        ipv6Prefix: value[index].internalNetwork[i].properties.bgpConfiguration.ipv6Prefix != '' ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6Prefix : null
        ipv4NeighborAddress: value[index].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress : null
        ipv6NeighborAddress: value[index].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress != [] ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress : null
      }
    }
  }]
  resource externalNetwork 'externalNetworks' = [for i in range(0, externalNetworkCount): {
    name: value[index].externalNetwork[i].name
    properties: {
      vlanId: value[index].externalNetwork[i].properties.vlanId
      mtu: value[index].externalNetwork[i].properties.mtu ? value[index].externalNetwork[i].properties.mtu : null
      fabricASN: value[index].externalNetwork[i].properties.fabricASN
      peerASN: value[index].externalNetwork[i].properties.peerASN
      primaryIpv4Prefix: value[index].externalNetwork[i].properties.primaryIpv4Prefix != '' ? value[index].externalNetwork[i].properties.primaryIpv4Prefix : null
      primaryIpv6Prefix: value[index].externalNetwork[i].properties.primaryIpv6Prefix != '' ? value[index].externalNetwork[i].properties.primaryIpv6Prefix : null
      secondaryIpv4Prefix: value[index].externalNetwork[i].properties.secondaryIpv4Prefix != '' ? value[index].externalNetwork[i].properties.secondaryIpv4Prefix : null
      secondaryIpv6Prefix: value[index].externalNetwork[i].properties.secondaryIpv6Prefix != '' ? value[index].externalNetwork[i].properties.secondaryIpv6Prefix : null
    }
  }]
}
