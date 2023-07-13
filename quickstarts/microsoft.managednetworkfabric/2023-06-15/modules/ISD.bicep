@description('Name of L3 domain')
param l3DomainName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string

@description('List of L3 domain')
param ISDList object

@description('Array Index value')
param index int

@description('NetworkFabric Id')
param fabricId string

var value = [for item in items(ISDList): item.value]

var internalNetworkCount = length(value[index].internalNetwork)
var externalNetworkCount = length(value[index].externalNetwork)


@description('Create L3 Isolation Domain  Resource')
resource l3IsolationDomains 'Microsoft.ManagedNetworkFabric/l3IsolationDomains@2023-06-15' = {
  name: l3DomainName
  location: location
  properties: {
    networkFabricId: fabricId
    annotation: contains(value[index].properties, 'annotation') ? value[index].properties.annotation : null
    redistributeConnectedSubnets: contains(value[index].properties, 'redistributeConnectedSubnets') ? value[index].properties.redistributeConnectedSubnets : 'True'
    redistributeStaticRoutes: contains(value[index].properties, 'redistributeStaticRoutes') ? value[index].properties.redistributeStaticRoutes : 'False'
    aggregateRouteConfiguration: contains(value[index].properties, 'aggregateRouteConfiguration') ? value[index].properties.aggregateRouteConfigurationList : null      // need to handle looping in conditional statement
    connectedSubnetRoutePolicy: contains(value[index].properties, 'connectedSubnetRoutePolicy') ? {
      exportRoutePolicy: contains(value[index].properties.connectedSubnetRoutePolicy, 'exportRoutePolicy') ? value[index].properties.connectedSubnetRoutePolicy.exportRoutePolicy : null
    } : null
  }
  resource internalNetwork 'internalNetworks' = [for i in range(0, internalNetworkCount):  {
    name: value[index].internalNetwork[i].name
    properties: {
      annotation: contains(value[index].internalNetwork[i].properties, 'annotation') ? value[index].internalNetwork[i].properties.annotation : null
      vlanId: value[index].internalNetwork[i].properties.vlanId
      isMonitoringEnabled: contains(value[index].internalNetwork[i].properties, 'isMonitoringEnabled') ? value[index].internalNetwork[i].properties.isMonitoringEnabled : 'False'
      extension: contains(value[index].internalNetwork[i].properties, 'extension') ? value[index].internalNetwork[i].properties.extension : 'NoExtension'
      mtu: contains(value[index].internalNetwork[i].properties, 'mtu') ? value[index].internalNetwork[i].properties.mtu : null
      connectedIPv4Subnets: contains(value[index].internalNetwork[i].properties, 'connectedIPv4Subnets') ? value[index].internalNetwork[i].properties.connectedIPv4Subnets : null     // need to handle looping in conditional statement
      connectedIPv6Subnets: contains(value[index].internalNetwork[i].properties, 'connectedIPv6Subnets') ? value[index].internalNetwork[i].properties.connectedIPv6Subnets : null     // need to handle looping in conditional statement
      staticRouteConfiguration: contains(value[index].internalNetwork[i].properties, 'staticRouteConfiguration') ? {
        bfdConfiguration: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration, 'bfdConfiguration') ? {
          intervalInMilliSeconds: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration.bfdConfiguration, 'intervalInMilliSeconds') ? value[index].internalNetwork[i].properties.staticRouteConfiguration.bfdConfiguration.intervalInMilliSeconds : null
          multiplier: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration.bfdConfiguration, 'multiplier') ? value[index].internalNetwork[i].properties.staticRouteConfiguration.bfdConfiguration.multiplier : null
        } : null
        ipv4Routes: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration, 'ipv4Routes') ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv4Routes : null     // need to handle looping in conditional statement
        ipv6Routes: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration, 'ipv6Routes') ? value[index].internalNetwork[i].properties.staticRouteConfiguration.ipv6Routes : null     // need to handle looping in conditional statement
        extension: contains(value[index].internalNetwork[i].properties.staticRouteConfiguration, 'extension') ? value[index].internalNetwork[i].properties.staticRouteConfiguration.extension : 'NoExtension'
      } : null
      bgpConfiguration: contains(value[index].internalNetwork[i].properties, 'bgpConfiguration') ? {
        bfdConfiguration: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'bfdConfiguration') ? {
          intervalInMilliSeconds: contains(value[index].internalNetwork[i].properties.bgpConfiguration.bfdConfiguration, 'intervalInMilliSeconds') ? value[index].internalNetwork[i].properties.bgpConfiguration.bfdConfiguration.intervalInMilliSeconds : null
          multiplier: contains(value[index].internalNetwork[i].properties.bgpConfiguration.bfdConfiguration, 'multiplier') ? value[index].internalNetwork[i].properties.bgpConfiguration.bfdConfiguration.multiplier : null
        } : null
        defaultRouteOriginate: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'defaultRouteOriginate') ? value[index].internalNetwork[i].properties.bgpConfiguration.defaultRouteOriginate : null
        allowAS: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'allowAS') ? value[index].internalNetwork[i].properties.bgpConfiguration.allowAS : null
        allowASOverride: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'allowASOverride') ? value[index].internalNetwork[i].properties.bgpConfiguration.allowASOverride : 'Enable'
        peerASN: value[index].internalNetwork[i].properties.bgpConfiguration.peerASN
        ipv4ListenRangePrefixes: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'ipv4ListenRangePrefixes') ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4ListenRangePrefixes : null
        ipv6ListenRangePrefixes: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'ipv6ListenRangePrefixes') ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6ListenRangePrefixes : null
        ipv4NeighborAddress: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'ipv4NeighborAddress') ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv4NeighborAddress : null      // need to handle looping in conditional statement
        ipv6NeighborAddress: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'ipv6NeighborAddress') ? value[index].internalNetwork[i].properties.bgpConfiguration.ipv6NeighborAddress : null      // need to handle looping in conditional statement
        annotation: contains(value[index].internalNetwork[i].properties.bgpConfiguration, 'annotation') ? value[index].internalNetwork[i].properties.bgpConfiguration.annotation : null
      } : null
      importRoutePolicy: contains(value[index].internalNetwork[i].properties, 'importRoutePolicy') ? {
        importIpv4RoutePolicyId: contains(value[index].internalNetwork[i].properties.importRoutePolicy, 'importIpv4RoutePolicyId') ? value[index].internalNetwork[i].properties.importRoutePolicy.importIpv4RoutePolicyId : null
        importIpv6RoutePolicyId: contains(value[index].internalNetwork[i].properties.importRoutePolicy, 'importIpv6RoutePolicyId') ? value[index].internalNetwork[i].properties.importRoutePolicy.importIpv6RoutePolicyId : null
      } : null
      exportRoutePolicy: contains(value[index].internalNetwork[i].properties, 'exportRoutePolicy') ? {
        exportIpv4RoutePolicyId: contains(value[index].internalNetwork[i].properties.exportRoutePolicy, 'exportIpv4RoutePolicyId') ? value[index].internalNetwork[i].properties.exportRoutePolicy.exportIpv4RoutePolicyId : null
        exportIpv6RoutePolicyId: contains(value[index].internalNetwork[i].properties.exportRoutePolicy, 'exportIpv6RoutePolicyId') ? value[index].internalNetwork[i].properties.exportRoutePolicy.exportIpv6RoutePolicyId : null
      } : null
    }
  }]

  resource externalNetwork 'externalNetworks' = [for i in range(0, externalNetworkCount): {
    name: value[index].externalNetwork[i].name
    properties: {
      peeringOption: value[index].externalNetwork[i].properties.peeringOption
      annotation: contains(value[index].externalNetwork[i].properties, 'annotation') ? value[index].externalNetwork[i].properties.annotation : null
      optionAProperties: contains(value[index].externalNetwork[i].properties, 'optionAProperties') ? {
        bfdConfiguration: contains(value[index].externalNetwork[i].properties.optionAProperties, 'bfdConfiguration') ? {
          intervalInMilliSeconds: contains(value[index].externalNetwork[i].properties.optionAProperties.bfdConfiguration, 'intervalInMilliSeconds') ? value[index].externalNetwork[i].properties.optionAProperties.bfdConfiguration.intervalInMilliSeconds : null
          multiplier: contains(value[index].externalNetwork[i].properties.optionAProperties.bfdConfiguration, 'multiplier') ? value[index].externalNetwork[i].properties.optionAProperties.bfdConfiguration.multiplier : null
        } : null
        mtu: contains(value[index].externalNetwork[i].properties.optionAProperties, 'mtu') ? value[index].externalNetwork[i].properties.optionAProperties.mtu : null
        vlanId: value[index].externalNetwork[i].properties.optionAProperties.vlanId
        peerASN: value[index].externalNetwork[i].properties.optionAProperties.peerASN
        primaryIpv4Prefix: contains(value[index].externalNetwork[i].properties.optionAProperties, 'primaryIpv4Prefix') ? value[index].externalNetwork[i].properties.optionAProperties.primaryIpv4Prefix : null
        primaryIpv6Prefix: contains(value[index].externalNetwork[i].properties.optionAProperties, 'primaryIpv6Prefix') ? value[index].externalNetwork[i].properties.optionAProperties.primaryIpv6Prefix : null
        secondaryIpv4Prefix: contains(value[index].externalNetwork[i].properties.optionAProperties, 'secondaryIpv4Prefix') ? value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv4Prefix : null
        secondaryIpv6Prefix: contains(value[index].externalNetwork[i].properties.optionAProperties, 'secondaryIpv6Prefix') ? value[index].externalNetwork[i].properties.optionAProperties.secondaryIpv6Prefix : null
      } : null
      optionBProperties: contains(value[index].externalNetwork[i].properties, 'optionBProperties') ? {
        routeTargets: contains(value[index].externalNetwork[i].properties.optionBProperties, 'routeTargets') ? {
          importIpv4RouteTargets: contains(value[index].externalNetwork[i].properties.optionBProperties.routeTargets, 'importIpv4RouteTargets') ? value[index].externalNetwork[i].properties.optionBProperties.importIpv4RouteTargets : null
            importIpv6RouteTargets: contains(value[index].externalNetwork[i].properties.optionBProperties, 'importIpv6RouteTargets') ? value[index].externalNetwork[i].properties.optionBProperties.importIpv6RouteTargets : null
            exportIpv4RouteTargets: contains(value[index].externalNetwork[i].properties.optionBProperties, 'exportIpv4RouteTargets') ? value[index].externalNetwork[i].properties.optionBProperties.exportIpv4RouteTargets : null
            exportIpv6RouteTargets: contains(value[index].externalNetwork[i].properties.optionBProperties, 'exportIpv6RouteTargets') ? value[index].externalNetwork[i].properties.optionBProperties.exportIpv6RouteTargets : null
        } : null
      } : null
      importRoutePolicy: contains(value[index].externalNetwork[i].properties, 'importRoutePolicy') ? {
        importIpv4RoutePolicyId: contains(value[index].externalNetwork[i].properties.importRoutePolicy, 'importIpv4RoutePolicyId') ? value[index].externalNetwork[i].properties.importRoutePolicy.importIpv4RoutePolicyId : null
        importIpv6RoutePolicyId: contains(value[index].externalNetwork[i].properties.importRoutePolicy, 'importIpv6RoutePolicyId') ? value[index].externalNetwork[i].properties.importRoutePolicy.importIpv6RoutePolicyId : null
      } : null
      exportRoutePolicy: contains(value[index].externalNetwork[i].properties, 'exportRoutePolicy') ? {
        exportIpv4RoutePolicyId: contains(value[index].externalNetwork[i].properties.exportRoutePolicy, 'exportIpv4RoutePolicyId') ? value[index].externalNetwork[i].properties.exportRoutePolicy.exportIpv4RoutePolicyId : null
        exportIpv6RoutePolicyId: contains(value[index].externalNetwork[i].properties.exportRoutePolicy, 'exportIpv6RoutePolicyId') ? value[index].externalNetwork[i].properties.exportRoutePolicy.exportIpv6RoutePolicyId : null
      } : null
    }
  }]
}
