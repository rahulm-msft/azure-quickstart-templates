@description('Name of the Ip Extended Community')
param ipExtendedCommunityName string

@description('Azure Region for deployment of the Ip Prefix and associated resources')
param location string = resourceGroup().location

@description('Action')
@allowed([
  'Permit'
  'Deny'
])
param action string

@description('Route Target List. The expected formats are ASN(plain):NN >> example 4294967294:50, ASN.ASN:NN >> example 65533.65333:40, IP-address:NN >> example 10.10.10.10:65535. The possible values of ASN,NN are in range of 0-65535, ASN(plain) is in range of 0-4294967295.')
param routeTargets array

resource ipExtendedCommunity 'Microsoft.ManagedNetworkFabric/ipExtendedCommunities@2023-02-01-preview' = {
  name: ipExtendedCommunityName
  location: location
  properties: {
    action: action
    routeTargets: routeTargets
  }
}

output resourceID string = ipExtendedCommunity.id
