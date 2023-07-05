@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Express route dedicated for Infrastructure services')
param infrastructureExpressRouteConnections array = []

@description('Express route is dedicated for Workload services')
param workloadExpressRouteConnections array = []

@description('Ipv4 address space used for NFC workload management')
param ipv4AddressSpace string = ''

@description('Ipv6 address space used for NFC workload management')
param ipv6AddressSpace string = ''

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2023-02-01-preview' = {
  name: networkFabricControllerName
  location: location
  properties: {
    infrastructureExpressRouteConnections: [for i in range(0, length(infrastructureExpressRouteConnections)): {
      expressRouteCircuitId: infrastructureExpressRouteConnections[i].expressRouteCircuitId
      expressRouteAuthorizationKey: infrastructureExpressRouteConnections[i].expressRouteAuthorizationKey
    }]
    workloadExpressRouteConnections: [for i in range(0, length(workloadExpressRouteConnections)): {
      expressRouteCircuitId: workloadExpressRouteConnections[i].expressRouteCircuitId
      expressRouteAuthorizationKey: workloadExpressRouteConnections[i].expressRouteAuthorizationKey
    }]
    ipv4AddressSpace: ipv4AddressSpace != '' ? ipv4AddressSpace : null
    ipv6AddressSpace: ipv6AddressSpace != '' ? ipv6AddressSpace : null
  }
}

output resourceID string = networkFabricController.id
