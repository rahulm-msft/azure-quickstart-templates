@description('Name of the Ip Community')
param ipCommunityName string

@description('Azure Region for deployment of the Ip Community and associated resources')
param location string = resourceGroup().location

@description('Action')
@allowed([
  'Permit'
  'Deny'
])
param action string

@description('Supported well known Community List')
@allowed([
  'Internet'
  'LocalAS'
  'NoAdvertise'
  'NoExport'
  'GShut'
])
param wellKnownCommunities array

@description('CommunityMembers of the Ip Community')
param communityMembers array

@description('Create Ip Community Resource')
resource ipCommunity 'Microsoft.ManagedNetworkFabric/ipCommunities@2023-02-01-preview' = {
  name: ipCommunityName
  location: location
  properties: {
    action: action
    wellKnownCommunities: wellKnownCommunities
    communityMembers: communityMembers
  }
}

output resourceID string = ipCommunity.id
