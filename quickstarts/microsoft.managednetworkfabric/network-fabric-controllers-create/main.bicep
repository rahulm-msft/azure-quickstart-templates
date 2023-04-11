@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Name of Express Route circuit')
param infraExRCircuitId string

@description('Authorization key for the circuit')
param infraExRAuthKey string

@description('Name of Express Route circuit')
param workloadExRCircuitId string

@description('Authorization key for the circuit')
param workloadExRAuthKey string

@description('Ipv4 address space used for NFC workload management')
param ipv4AddressSpace string

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2023-02-01-preview' = {
  name: networkFabricControllerName
  location: location
  properties: {
    infrastructureExpressRouteConnections: [
      {
        expressRouteCircuitId: infraExRCircuitId
        expressRouteAuthorizationKey: infraExRAuthKey
      }
    ]
    workloadExpressRouteConnections: [
      {
        expressRouteCircuitId: workloadExRCircuitId
        expressRouteAuthorizationKey: workloadExRAuthKey
      }
    ]
    ipv4AddressSpace: ipv4AddressSpace
  }
}

output resourceID string = networkFabricController.id
