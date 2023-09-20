@description('Name of the Route Access Control Lists')
param accessControlListName string

@description('Azure Region for deployment of the Route Access Control Lists and associated resources')
param location string = resourceGroup().location

@description('Description for underlying resource')
param annotation string = ''

@description('Input method to configure Access Control List')
param configurationType string

@description('Access Control List file URL')
param aclsUrl string

@description('Default action that needs to be applied when no condition is matched')
param defaultAction string

@description('List of match configurations')
param matchConfigurations array = []

@description('List of dynamic match configurations')
param dynamicMatchConfigurations array = []

@description('Create Route Access Control Lists Resource')
resource accessControlLists 'Microsoft.ManagedNetworkFabric/accessControlLists@2023-06-15' = {
  name: accessControlListName
  location: location
  properties: {
    annotation: !empty(annotation) ? annotation : null
    configurationType : configurationType
    aclsUrl: aclsUrl
    defaultAction: defaultAction
    matchConfigurations: [for i in (!empty(matchConfigurations) ? range(0, length(matchConfigurations)) : []): {
      matchConfigurationName: matchConfigurations[i].matchConfigurationName
      sequenceNumber: matchConfigurations[i].sequenceNumber
      ipAddressType: matchConfigurations[i].ipAddressType
      matchConditions: matchConfigurations[i].matchConditions
      actions: matchConfigurations[i].actions
    }]
    dynamicMatchConfigurations: [for i in (!empty(dynamicMatchConfigurations) ? range(0, length(dynamicMatchConfigurations)) : []): {
      ipGroups: dynamicMatchConfigurations[i].ipGroups
      vlanGroups: dynamicMatchConfigurations[i].vlanGroups
      portGroups: dynamicMatchConfigurations[i].portGroups
    }]
  }
}

output resourceID string = accessControlLists.id
