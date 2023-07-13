@description('Name of the Network Fabric Controller Resource Group')
param nfcResourceGroupName string

// NFC
@description('Name of the Network Fabric Controller')
param networkFabricControllerName string

@description('Azure Region for deployment of the Network Fabric Controller and associated resources')
param location string = resourceGroup().location

@description('Switch configuration description')
param nfcAnnotation string = ''

@description('A workload management network is required for all the tenant (workload) traffic. This traffic is only dedicated for Tenant workloads which are required to access internet or any other MSFT/Public endpoints')
@allowed([
  'False'
  'True'
])
param isWorkloadManagementNetworkEnabled string = 'True'

@description('Network Fabric Controller SKU')
@allowed([
  'Basic'
  'HighPerformance'
  'Standard'
])
param nfcSku string = 'Standard'

@description('Express route dedicated for Infrastructure services')
param infrastructureExpressRouteConnections array = []

@description('Express route is dedicated for Workload services')
param workloadExpressRouteConnections array = []

@description('Ipv4 address space used for NFC workload management')
param ipv4AddressSpace string = ''

@description('Ipv6 address space used for NFC workload management')
param ipv6AddressSpace string = ''

// NF
@description('Name of the Network Fabric')
param networkFabricName string

@description('Switch configuration description')
param nfAnnotation string = ''

@description('Resource Id of the Network Fabric Controller,  is should be in the format of /subscriptions/<Sub ID>/resourceGroups/<Resource group name>/providers/Microsoft.ManagedNetworkFabric/networkFabricControllers/<networkFabricController name>')
param networkFabricControllerId string

@description('Name of the Network Fabric SKU')
param networkFabricSku string

@minValue(1)
@maxValue(8)
@description('Number of racks associated to Network Fabric')
param rackCount int

@minValue(1)
@maxValue(16)
@description('Number of servers per Rack')
param serverCountPerRack int

@description('IPv4 Prefix for Management Network')
param ipv4Prefix string

@description('IPv6 Prefix for Management Network')
param ipv6Prefix string = ''

@minValue(1)
@maxValue(4294967295)
@description('ASN of CE devices for CE/PE connectivity')
param fabricASN int

@description('Network and credentials configuration currently applied to terminal server')
param terminalServerConfiguration object

@description('Configuration to be used to setup the management network')
param managementNetworkConfiguration object

// NNI
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
param isManagementType string = 'True'

@description('Based on this parameter the layer2/layer3 is made as mandatory')
@allowed([
  'True'
  'False'
])
param useOptionB string

@description('Common properties for Layer2Configuration')
param layer2Configuration object = {}

@description('Common properties for optionBLayer3Configuration')
param optionBLayer3Configuration object = {}

@description('NPB Static Route Configuration properties')
param npbStaticRouteConfiguration object = {}

@description('Import Route Policy configuration')
param importRoutePolicy object = {}

@description('Export Route Policy configuration')
param exportRoutePolicy object = {}

// Deployment Script
@description('Name of the Managed Identity')
param userIdentityName string

// Device
@description('List of Device to be updated ie., deviceName:serialNumber')
param deviceMap object

var deviceNameList = [for item in items(deviceMap): item.key]

var serialNumberList = [for item in items(deviceMap): item.value]

var deviceCount = length(deviceNameList)

@description('Name of the Deployment Script')
param deploymentScriptsName string

@description('URL of the globally available wheel file')
param wheelFileURL string

// L2 Domain
@description('List of L2domain to be created')
param l2Domain object

var l2DomainsName = [for item in items(l2Domain): item.key]

var l2DomainsProperties = [for item in items(l2Domain): item.value]

var l2DomainCount = length(l2DomainsName)

// IpPrefix
@description('Name of the Ip Prefix')
param ipPrefixName string

@description('Switch configuration description')
param IpPrefixAnnotation string = ''

@description('Ip Prefix')
param ipPrefixRules array

// IpCommunity
@description('Name of the Ip Community')
param ipCommunityName string

@description('Switch configuration description')
param ipCommunityAnnotation string = ''

@description('List of IP Community Rules')
param ipCommunityRules array

// IpExtendedCommunity
@description('Name of the Ip Extended Community')
param ipExtendedCommunityName string

@description('Switch configuration description')
param ipExtCommunityAnnotation string = ''

@description('List of IP Extended Community Rules')
param ipExtendedCommunityRules array

// Route Policy
@description('Name of the Route Policy')
param routePolicyName string

@description('Route Policy statements')
param statements array

@description('Switch configuration description')
param routePolicyAnnotation string = ''

// L3 Domain, Internal Network, External Network
@description('List of L3domain and Internal/External Networks to be created')
param ISD object

var l3DomainsName = [for item in items(ISD): item.key]

var l3DomainCount = length(l3DomainsName)

@description('Create Network Fabric Controller Resource')
module nfc './modules/NFC.bicep' = {
  name: 'nfc'
  scope: resourceGroup(nfcResourceGroupName)
  params: {
    location: location
    networkFabricControllerName: networkFabricControllerName
    annotation: nfcAnnotation
    isWorkloadManagementNetworkEnabled: isWorkloadManagementNetworkEnabled
    nfcSku: nfcSku
    infrastructureExpressRouteConnections: infrastructureExpressRouteConnections
    workloadExpressRouteConnections: workloadExpressRouteConnections
    ipv4AddressSpace: ipv4AddressSpace
    ipv6AddressSpace: ipv6AddressSpace
  }
}

@description('Create Network Fabric Resource')
resource networkFabrics 'Microsoft.ManagedNetworkFabric/networkFabrics@2023-06-15' = {
  name: networkFabricName
  location: location
  properties: {
    annotation: !empty(nfAnnotation) ? nfAnnotation : null
    networkFabricSku: networkFabricSku
    rackCount: rackCount
    serverCountPerRack: serverCountPerRack
    ipv4Prefix: ipv4Prefix
    ipv6Prefix: !empty(ipv6Prefix) ? ipv6Prefix : null
    fabricASN: fabricASN
    networkFabricControllerId: nfc.outputs.resourceID
    terminalServerConfiguration: {
      username: terminalServerConfiguration.username
      password: terminalServerConfiguration.password
      serialNumber: contains(terminalServerConfiguration, 'serialNumber') ? terminalServerConfiguration.serialNumber : null
      primaryIpv4Prefix: terminalServerConfiguration.primaryIpv4Prefix
      primaryIpv6Prefix: contains(terminalServerConfiguration, 'primaryIpv6Prefix') ? terminalServerConfiguration.primaryIpv6Prefix : null
      secondaryIpv4Prefix: terminalServerConfiguration.secondaryIpv4Prefix
      secondaryIpv6Prefix: contains(terminalServerConfiguration, 'secondaryIpv6Prefix') ? terminalServerConfiguration.secondaryIpv6Prefix : null
    }
    managementNetworkConfiguration: {
      infrastructureVpnConfiguration: {
        peeringOption: managementNetworkConfiguration.infrastructureVpnConfiguration.peeringOption
        networkToNetworkInterconnectId: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'networkToNetworkInterconnectId') ? managementNetworkConfiguration.infrastructureVpnConfiguration.networkToNetworkInterconnectId : null
        optionBProperties: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'optionBProperties') ? {
          routeTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties, 'routeTargets') ? {
            importIpv4RouteTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets, 'importIpv4RouteTargets') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets.importIpv4RouteTargets : null
            importIpv6RouteTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets, 'importIpv6RouteTargets') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets.importIpv6RouteTargets : null
            exportIpv4RouteTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets, 'exportIpv4RouteTargets') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets.exportIpv4RouteTargets : null
            exportIpv6RouteTargets: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets, 'exportIpv6RouteTargets') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionBProperties.routeTargets.exportIpv6RouteTargets : null
          } : null
        } : null
        optionAProperties: contains(managementNetworkConfiguration.infrastructureVpnConfiguration, 'optionAProperties') ? {
          mtu: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'mtu') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.mtu : null
          vlanId: managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.vlanId
          peerASN: managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.peerASN
          bfdConfiguration: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'bfdConfiguration') ? {
            intervalInMilliSeconds: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.bfdConfiguration, 'intervalInMilliSeconds') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.bfdConfiguration.intervalInMilliSeconds : null
            multiplier: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.bfdConfiguration, 'multiplier') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.bfdConfiguration.multiplier : null
          } : null
          primaryIpv4Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'primaryIpv4Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.primaryIpv4Prefix : null
          primaryIpv6Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'primaryIpv6Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.primaryIpv6Prefix : null
          secondaryIpv4Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'secondaryIpv4Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.secondaryIpv4Prefix : null
          secondaryIpv6Prefix: contains(managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties, 'secondaryIpv6Prefix') ? managementNetworkConfiguration.infrastructureVpnConfiguration.optionAProperties.secondaryIpv6Prefix : null
        } : null
      }
      workloadVpnConfiguration: {
        peeringOption: managementNetworkConfiguration.workloadVpnConfiguration.peeringOption
        networkToNetworkInterconnectId: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'networkToNetworkInterconnectId') ? managementNetworkConfiguration.workloadVpnConfiguration.networkToNetworkInterconnectId : null
        optionBProperties: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'optionBProperties') ? {
          routeTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties, 'routeTargets') ? {
            importIpv4RouteTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets, 'importIpv4RouteTargets') ? managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets.importIpv4RouteTargets : null
            importIpv6RouteTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets, 'importIpv6RouteTargets') ? managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets.importIpv6RouteTargets : null
            exportIpv4RouteTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets, 'exportIpv4RouteTargets') ? managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets.exportIpv4RouteTargets : null
            exportIpv6RouteTargets: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets, 'exportIpv6RouteTargets') ? managementNetworkConfiguration.workloadVpnConfiguration.optionBProperties.routeTargets.exportIpv6RouteTargets : null
          } : null
        } : null
        optionAProperties: contains(managementNetworkConfiguration.workloadVpnConfiguration, 'optionAProperties') ? {
          mtu: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'mtu') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.mtu : null
          vlanId: managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.vlanId
          peerASN: managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.peerASN
          bfdConfiguration: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'bfdConfiguration') ? {
            intervalInMilliSeconds: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.bfdConfiguration, 'intervalInMilliSeconds') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.bfdConfiguration.intervalInMilliSeconds : null
            multiplier: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.bfdConfiguration, 'multiplier') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.bfdConfiguration.multiplier : null
          } : null
          primaryIpv4Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'primaryIpv4Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.primaryIpv4Prefix : null
          primaryIpv6Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'primaryIpv6Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.primaryIpv6Prefix : null
          secondaryIpv4Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'secondaryIpv4Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.secondaryIpv4Prefix : null
          secondaryIpv6Prefix: contains(managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties, 'secondaryIpv6Prefix') ? managementNetworkConfiguration.workloadVpnConfiguration.optionAProperties.secondaryIpv6Prefix : null
        } : null
      }
    }
  }
  resource networkToNetworkInterconnect 'networkToNetworkInterconnects' = {
    name: networkToNetworkInterconnectName
    properties: {
      nniType: nniType
      isManagementType: isManagementType
      useOptionB: useOptionB
      layer2Configuration: !empty(layer2Configuration) ? {
        interfaces: contains(layer2Configuration, 'interfaces') ? layer2Configuration.interfaces : null
        mtu: contains(layer2Configuration, 'mtu') ? layer2Configuration.mtu : null
      } : null
      optionBLayer3Configuration: !empty(optionBLayer3Configuration) ? {
        peerASN: optionBLayer3Configuration.peerASN
        vlanId: optionBLayer3Configuration.vlanId
        primaryIpv4Prefix: contains(optionBLayer3Configuration, 'primaryIpv4Prefix') ? optionBLayer3Configuration.primaryIpv4Prefix : null
        primaryIpv6Prefix: contains(optionBLayer3Configuration, 'primaryIpv6Prefix') ? optionBLayer3Configuration.primaryIpv6Prefix : null
        secondaryIpv4Prefix: contains(optionBLayer3Configuration, 'secondaryIpv4Prefix') ? optionBLayer3Configuration.secondaryIpv4Prefix : null
        secondaryIpv6Prefix: contains(optionBLayer3Configuration, 'secondaryIpv6Prefix') ? optionBLayer3Configuration.secondaryIpv6Prefix : null
      } : null
      npbStaticRouteConfiguration: !empty(npbStaticRouteConfiguration) ? {
        bfdConfiguration: contains(npbStaticRouteConfiguration, 'bfdConfiguration') ? {
          intervalInMilliSeconds: contains(npbStaticRouteConfiguration.bfdConfiguration, 'intervalInMilliSeconds') ? npbStaticRouteConfiguration.bfdConfiguration.intervalInMilliSeconds : null
          multiplier: contains(npbStaticRouteConfiguration.bfdConfiguration, 'multiplier') ? npbStaticRouteConfiguration.bfdConfiguration.multiplier : null
        } : null
        ipv4Routes: contains(npbStaticRouteConfiguration, 'ipv4Routes') ? npbStaticRouteConfiguration.ipv4Routes : null     // need to handle looping in conditional statement
        ipv6Routes: contains(npbStaticRouteConfiguration, 'ipv6Routes') ? npbStaticRouteConfiguration.ipv6Routes : null     // need to handle looping in conditional statement
      } : null
      importRoutePolicy: !empty(importRoutePolicy) ? {
        importIpv4RoutePolicyId: contains(importRoutePolicy, 'importIpv4RoutePolicyId') ? importRoutePolicy.importIpv4RoutePolicyId : null
        importIpv6RoutePolicyId: contains(importRoutePolicy, 'importIpv6RoutePolicyId') ? importRoutePolicy.importIpv6RoutePolicyId : null
      } : null
      exportRoutePolicy: !empty(exportRoutePolicy) ? {
        exportIpv4RoutePolicyId: contains(exportRoutePolicy, 'exportIpv4RoutePolicyId') ? exportRoutePolicy.exportIpv4RoutePolicyId : null
        exportIpv6RoutePolicyId: contains(exportRoutePolicy, 'exportIpv6RoutePolicyId') ? exportRoutePolicy.exportIpv6RoutePolicyId : null
      } : null
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

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
  scope: subscription()
  name: '009cde5c-dcd4-4b51-a5f9-02cd31c908ed'
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
    scriptContent: loadTextContent('scripts/deviceUpdate.sh')
    azCliVersion: '2.49.0'
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
        name: 'SERIALNUMBER'
        value: serialNumberList[i]
      }
    ]
  }
}]

resource networkFabricProvision 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'networkFabricProvision'
  location: location
  dependsOn: [
    updateSerialNumber
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: loadTextContent('scripts/provision.sh')
    azCliVersion: '2.49.0'
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
        name: 'FABRICNAME'
        value: networkFabrics.name
      }
    ]
  }
}

@description('Create L2 Isolation Domain Resource')
resource l2IsolationDomains 'Microsoft.ManagedNetworkFabric/l2IsolationDomains@2023-06-15' = [for i in range(0, l2DomainCount):  {
  name: l2DomainsName[i]
  location: location
  dependsOn: [
    networkFabricProvision
  ]
  properties: {
    annotation: contains(l2DomainsProperties[i].properties, 'annotation') ? l2DomainsProperties[i].properties.annotation : null
    networkFabricId: networkFabrics.id
    vlanId: l2DomainsProperties[i].properties.vlanId
    mtu: contains(l2DomainsProperties[i].properties, 'mtu') ? l2DomainsProperties[i].properties.mtu : null
  }
}]

resource l2DomainUpdateAdminState 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, l2DomainCount): {
  name: '${deploymentScriptsName}-L2UAS-${i}'
  location: location
  dependsOn: [
    l2IsolationDomains
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az networkfabric l2domain update-admin-state --resource-name "${l2DomainsName[i]}" --resource-group ${resourceGroup().name} --state "Enable"'
    azCliVersion: '2.49.0'
    retentionInterval: 'PT4H'
  }
}]

@description('Create Ip Prefix Resource')
resource ipPrefix 'Microsoft.ManagedNetworkFabric/ipPrefixes@2023-06-15' = {
  name: ipPrefixName
  location: location
  properties: {
    annotation: !empty(IpPrefixAnnotation) ? IpPrefixAnnotation : null
    ipPrefixRules: [for i in range(0, length(ipPrefixRules)): {
      action: ipPrefixRules[i].action
      sequenceNumber: ipPrefixRules[i].sequenceNumber
      networkPrefix: ipPrefixRules[i].networkPrefix
      condition: contains(ipPrefixRules[i], 'condition') ? ipPrefixRules[i].condition : null
      subnetMaskLength: contains(ipPrefixRules[i], 'subnetMaskLength') ? ipPrefixRules[i].subnetMaskLength : null
    }]
  }
}

@description('Create Ip Community Resource')
resource ipCommunity 'Microsoft.ManagedNetworkFabric/ipCommunities@2023-06-15' = {
  name: ipCommunityName
  location: location
  properties: {
    annotation: !empty(ipCommunityAnnotation) ? ipCommunityAnnotation : null
    ipCommunityRules: [for i in range(0, length(ipCommunityRules)): {
      action: ipCommunityRules[i].action
      sequenceNumber: ipCommunityRules[i].sequenceNumber
      wellKnownCommunities: contains(ipCommunityRules[i], 'wellKnownCommunities') ? ipCommunityRules[i].wellKnownCommunities : null
      communityMembers: ipCommunityRules[i].communityMembers
    }]
  }
}

@description('Create Ip Extended Community Resource')
resource ipExtendedCommunity 'Microsoft.ManagedNetworkFabric/ipExtendedCommunities@2023-06-15' = {
  name: ipExtendedCommunityName
  location: location
  properties: {
    annotation: !empty(ipExtCommunityAnnotation) ? ipExtCommunityAnnotation : null
    ipExtendedCommunityRules: [for i in range(0, length(ipExtendedCommunityRules)): {
      action: ipExtendedCommunityRules[i].action
      sequenceNumber: ipExtendedCommunityRules[i].sequenceNumber
      routeTargets: ipExtendedCommunityRules[i].routeTargets
    }]
  }
}

@description('Create Route Policy')
resource routePolicies 'Microsoft.ManagedNetworkFabric/routePolicies@2023-06-15' = {
  name: routePolicyName
  location: location
  properties: {
    annotation: !empty(routePolicyAnnotation) ? routePolicyAnnotation : null
    networkFabricId: networkFabrics.id
    statements: [for i in range(0, length(statements)): {
      sequenceNumber: statements[i].sequenceNumber
      condition: {
        ipCommunityIds: contains(statements[i].condition, 'ipCommunityIds') ? statements[i].condition.ipCommunityIds : null
        ipExtendedCommunityIds: contains(statements[i].condition, 'ipExtendedCommunityIds') ? statements[i].condition.ipExtendedCommunityIds : null
        ipPrefixId: contains(statements[i].condition, 'ipPrefixId') ? statements[i].condition.ipPrefixId : null
        type: contains(statements[i].condition, 'type') ? statements[i].condition.type : null
      }
      action: {
        localPreference: contains(statements[i].action, 'localPreference') ? statements[i].action.localPreference : null
        actionType: statements[i].action.actionType
        ipCommunityProperties: contains(statements[i].action, 'ipCommunityProperties') ? {
          add: contains(statements[i].action.ipCommunityProperties, 'add') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.add, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.add.ipCommunityIds : null
          } : null
          delete: contains(statements[i].action.ipCommunityProperties, 'delete') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.delete, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.delete.ipCommunityIds : null
          } : null
          set: contains(statements[i].action.ipCommunityProperties, 'set') ? {
            ipCommunityIds: contains(statements[i].action.ipCommunityProperties.set, 'ipCommunityIds') ? statements[i].action.ipCommunityProperties.set.ipCommunityIds : null
          } : null
        } : null
        ipExtendedCommunityProperties: contains(statements[i].action, 'ipExtendedCommunityProperties') ? {
          add: contains(statements[i].action.ipExtendedCommunityProperties, 'add') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.add, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.add.ipExtendedCommunityIds : null
          } : null
          delete: contains(statements[i].action.ipExtendedCommunityProperties, 'delete') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.delete, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.delete.ipExtendedCommunityIds : null
          } : null
          set: contains(statements[i].action.ipExtendedCommunityProperties, 'set') ? {
            ipExtendedCommunityIds: contains(statements[i].action.ipExtendedCommunityProperties.set, 'ipExtendedCommunityIds') ? statements[i].action.ipExtendedCommunityProperties.set.ipExtendedCommunityIds : null
          } : null
        } : null
      }
    }]
  }
}

module isd './modules/ISD.bicep' = [for i in range(0, l3DomainCount): {
  name: 'isd-${i}'
  dependsOn: [
    l2DomainUpdateAdminState
  ]
  params: {
    location: location
    l3DomainName: l3DomainsName[i]
    ISDList: ISD
    index: i
    fabricId: networkFabrics.id
  }
}]
