@description('Name of the Ip Prefix')
param ipPrefixName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Ip Prefix Rules')
param ipPrefixRules array

@description('Create Ip Prefix Resource')
resource ipPrefix 'Microsoft.ManagedNetworkFabric/ipPrefixes@2023-02-01-preview' = {
  name: ipPrefixName
  location: location
  properties: {
    ipPrefixRules: [for i in range(0, length(ipPrefixRules)): {
      action: ipPrefixRules[i].action
      sequenceNumber: ipPrefixRules[i].sequenceNumber
      networkPrefix: ipPrefixRules[i].networkPrefix
      condition: contains(ipPrefixRules[i], 'condition') ? ipPrefixRules[i].condition : null
      subnetMaskLength: contains(ipPrefixRules[i], 'subnetMaskLength') ? ipPrefixRules[i].subnetMaskLength : null
    }]
  }
}

output resourceID string = ipPrefix.id
