@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Name of the Network Fabric Controller Resource Group')
param nfcResourceGroupName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

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

@description('Name of the Network Fabric')
param networkFabricName string

@description('Name of the Network Fabric SKU')
param networkFabricSku string

@description('Layer2 Configuration of Network to Network Inter-connectivity configuration between CEs and PEs')
param nfNniLayer2conf object

@description('Layer3 Configuration of Network to Network Inter-connectivity configuration between CEs and PEs')
param nfNniLayer3conf object

@description('Username of terminal server')
param nfTSconfUsername string

@secure()
@description('Password of terminal server')
param nfTSconfPassword string

@description('IPv4 Prefix for connectivity between TS and PE1')
param nfTSconfPrimaryIpv4Prefix string

@description('IPv4 Prefix for connectivity between TS and PE12')
param nfTSconfSecondaryIpv4Prefix string

@description('IPv4 Prefix of the management network')
param nfMNconfIpv4Prefix string

@description('Manage the management VPN connection between Network Fabric and infrastructure services in Network Fabric Controller')
param nfMNconfManVpn object

@description('Manage the management VPN connection between Network Fabric and workload services in Network Fabric Controller')
param nfMNconfWorkloadVpn object

@description('List of Racks to be created')
param racks object

var racksName = [for item in items(racks): item.key]

var racksProperties = [for item in items(racks): item.value]

var rackCount = length(racksName)

@description('List of Device to be updated ie., deviceName:serialNumber')
param deviceMap object

var deviceNameList = [for item in items(deviceMap): item.key]

var serialNumberList = [for item in items(deviceMap): item.value]

var deviceCount = length(deviceNameList)

@description('Name of the Managed Identity')
param userIdentityName string

@description('Id of the Role')
param roleId string

@description('Role Definition ID')
param roleDefinitionId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleId}'

@description('Role Assignment Name')
param roleAssignmentName string = guid(userIdentityName, roleDefinitionId, resourceGroup().id)

@description('URL of the globally available wheel file')
param wheelFileURL string

@description('Name of the Deployment Script')
param deploymentScriptsName string

module nfc './NFC.bicep' = {
  name: 'nfc'
  scope: resourceGroup(nfcResourceGroupName)
  params: {
    location: location
    networkFabricControllerName: networkFabricControllerName
    nfcInfraExRAuthKey: nfcInfraExRAuthKey
    nfcInfraExRCircuitId: nfcInfraExRCircuitId
    nfcIpv4AddressSpace: nfcIpv4AddressSpace
    nfcWorkloadExRAuthKey: nfcWorkloadExRAuthKey
    nfcWorkloadExRCircuitId: nfcWorkloadExRCircuitId
  }
}

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2022-01-15-privatepreview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    networkFabricControllerId: nfc.outputs.resourceID
    networkToNetworkInterconnect: {
      layer2Configuration: nfNniLayer2conf
      layer3Configuration: nfNniLayer3conf
    }
    terminalServerConfiguration: {
      username: nfTSconfUsername
      password: nfTSconfPassword
      primaryIpv4Prefix: nfTSconfPrimaryIpv4Prefix
      secondaryIpv4Prefix: nfTSconfSecondaryIpv4Prefix
    }
    managementNetworkConfiguration: {
      ipv4Prefix: nfMNconfIpv4Prefix
      managementVpnConfiguration: nfMNconfManVpn
      workloadVpnConfiguration: nfMNconfWorkloadVpn
    }
  }
}

@description('Create Network Rack Resource')
resource networkRacks 'Microsoft.ManagedNetworkFabric/networkRacks@2022-01-15-privatepreview' = [for i in range(0, rackCount): {
  name: racksName[i]
  location: location
  properties: {
    networkRackSku: racksProperties[i].properties.networkRackSku
    networkFabricId: networkFabrics.id
  }
}]

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
  dependsOn: [
    networkRacks
  ]
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource updateSerialNumber 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, deviceCount): {
  name: '${deploymentScriptsName}-USN-${i}'
  location: location
  dependsOn: [
    roleAssign
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: loadTextContent('deviceUpdate.sh')
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
    environmentVariables: [
      {
        name: 'WHEEL_FILE_URL'
        value: wheelFileURL
      }
      {
        name: 'RESOURCEGROUP'
        value: resourceGroup().name
      }
      {
        name: 'DEVICENAME'
        value: deviceNameList[i]
      }
      {
        name: 'LOCATION'
        value: location
      }
      {
        name: 'SERIALNUMBER'
        value: serialNumberList[i]
      }
    ]
  }
}]
