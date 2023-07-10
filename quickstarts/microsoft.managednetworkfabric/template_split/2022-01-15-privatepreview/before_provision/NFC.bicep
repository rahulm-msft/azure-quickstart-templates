@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string

@description('Name of Express Route circuit')
param nfcInfraExRCircuitId string

@description('Authorization key for the circuit')
param nfcInfraExRAuthKey string

@description('Name of Express Route circuit')
param nfcWorkloadExRCircuitId string

@description('Authorization key for the circuit')
param nfcWorkloadExRAuthKey string

@description('Ipv4 address space used for NFC workload management')
param nfcIpv4AddressSpace string

@description('Create Network Fabric Controller Resource')
resource networkFabricController 'Microsoft.ManagedNetworkFabric/networkFabricControllers@2022-01-15-privatepreview' = {
  name: networkFabricControllerName
  location: location
  properties: {
    infrastructureExpressRouteConnections: [
      {
        expressRouteCircuitId: nfcInfraExRCircuitId
        expressRouteAuthorizationKey: nfcInfraExRAuthKey
      }
    ]
    workloadExpressRouteConnections: [
      {
        expressRouteCircuitId: nfcWorkloadExRCircuitId
        expressRouteAuthorizationKey: nfcWorkloadExRAuthKey
      }
    ]
    ipv4AddressSpace: nfcIpv4AddressSpace
  }
}

output resourceID string = networkFabricController.id
