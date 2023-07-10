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

param rackCount int

param serverCountPerRack int

param ipv4Prefix string

param ipv6Prefix string

param fabricASN int

@description('Username of terminal server')
param nfTSconfUsername string

@secure()
@description('Password of terminal server')
param nfTSconfPassword string

param nfTSconfSerialNumber string

@description('IPv4 Prefix for connectivity between TS and PE1')
param nfTSconfPrimaryIpv4Prefix string

param nfTSconfPrimaryIpv6Prefix string

@description('IPv4 Prefix for connectivity between TS and PE12')
param nfTSconfSecondaryIpv4Prefix string

param nfTSconfSecondaryIpv6Prefix string

@description('Manage the management VPN connection between Network Fabric and infrastructure services in Network Fabric Controller')
param nfMNconfInfraVpn object

@description('Manage the management VPN connection between Network Fabric and workload services in Network Fabric Controller')
param nfMNconfWorkloadVpn object

param networkToNetworkInterconnectName string

param isManagementType string

param useOptionB string

param layer2Configuration object

param layer3Configuration object

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

// module nfc './NFC.bicep' = {
//   name: 'nfc'
//   scope: resourceGroup(nfcResourceGroupName)
//   params: {
//     location: location
//     networkFabricControllerName: networkFabricControllerName
//     nfcInfraExRAuthKey: nfcInfraExRAuthKey
//     nfcInfraExRCircuitId: nfcInfraExRCircuitId
//     nfcIpv4AddressSpace: nfcIpv4AddressSpace
//     nfcWorkloadExRAuthKey: nfcWorkloadExRAuthKey
//     nfcWorkloadExRCircuitId: nfcWorkloadExRCircuitId
//   }
// }

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-02-01-preview' = {
  name: networkFabricName
  location: location
  properties: {
    networkFabricSku: networkFabricSku
    rackCount: rackCount
    serverCountPerRack: serverCountPerRack
    ipv4Prefix: ipv4Prefix != '' ? ipv4Prefix : null
    ipv6Prefix: ipv6Prefix != '' ? ipv6Prefix : null
    fabricASN: fabricASN
    networkFabricControllerId: '/subscriptions/d854f6e5-7f11-4515-9d58-2ef770a77ee2/resourceGroups/rahul-nfcrg031323/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/rahul-nfc031323' //nfc.outputs.resourceID
    terminalServerConfiguration: {
      username: nfTSconfUsername
      password: nfTSconfPassword
      serialNumber: nfTSconfSerialNumber
      primaryIpv4Prefix: nfTSconfPrimaryIpv4Prefix != '' ? nfTSconfPrimaryIpv4Prefix : null
      primaryIpv6Prefix: nfTSconfPrimaryIpv6Prefix != '' ? nfTSconfPrimaryIpv6Prefix : null
      secondaryIpv4Prefix: nfTSconfSecondaryIpv4Prefix != '' ? nfTSconfSecondaryIpv4Prefix : null
      secondaryIpv6Prefix: nfTSconfSecondaryIpv6Prefix != '' ? nfTSconfSecondaryIpv6Prefix : null
    }
    managementNetworkConfiguration: {
      infrastructureVpnConfiguration: nfMNconfInfraVpn
      workloadVpnConfiguration: nfMNconfWorkloadVpn
    }
  }
  resource networkToNetworkInterconnect 'networkToNetworkInterconnects' = {
    name: networkToNetworkInterconnectName
    properties: {
      isManagementType: isManagementType
      useOptionB: useOptionB
      layer2Configuration: layer2Configuration
      layer3Configuration: layer3Configuration
    }
  }
}

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
  dependsOn: [
    networkFabrics
  ]
}

// resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
//   scope: subscription()
//   name: '009cde5c-dcd4-4b51-a5f9-02cd31c908ed'
// }

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
