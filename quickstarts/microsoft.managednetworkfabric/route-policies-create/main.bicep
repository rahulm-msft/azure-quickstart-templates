@description('Name of the Route Policy')
param routePolicyName string

@description('Azure Region for deployment of the Route Policy and associated resources')
param location string = resourceGroup().location

@description('Route Policy statements')
param statements array

@description('Create Route Policy')
resource routePolicies 'Microsoft.ManagedNetworkFabric/routePolicies@2023-02-01-preview' = {
  name: routePolicyName
  location: location
  properties: {
    statements: statements
  }
}

output resourceID string = routePolicies.id
