@description('Name of the Ip Prefix')
param ipPrefixName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Ip Prefix')
param ipPrefixRules array

@description('Create Ip Prefix Resource')
resource ipPrefix 'Microsoft.ManagedNetworkFabric/ipPrefixes@2023-02-01-preview' = {
  name: ipPrefixName
  location: location
  properties: {
    ipPrefixRules: ipPrefixRules
  }
}

output resourceID string = ipPrefix.id
