@description('Location')
param location string = resourceGroup().location

@description('Name of Network Fabric')
param networkFabricsName string

@description('ID of Network Fabric')
param networkFabricsId string

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

@description('List of L2domain to be created')
param l2Domain object

var l2DomainsName = [for item in items(l2Domain): item.key]

var l2DomainsProperties = [for item in items(l2Domain): item.value]

var l2DomainCount = length(l2DomainsName)

@description('List of L3domain and Internal/External Networks to be created')
param ISD object

var l3DomainsName = [for item in items(ISD): item.key]

var l3DomainCount = length(l3DomainsName)

// resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
//   name: userIdentityName
// }

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
}

// resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
//   scope: subscription()
//   name: '59b4a675-7881-53c8-b8c3-2188cbc90aa1'
// }

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource networkFabricProvision 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'networkFabricProvision'
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
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az nf fabric provision -g "${resourceGroup().name}" --resource-name "${networkFabricsName}"; echo ${resourceGroup().name}; echo ${networkFabricsName}'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}

@description('Create L2 Isolation Domain Resource')
resource l2IsolationDomains 'Microsoft.ManagedNetworkFabric/l2IsolationDomains@2022-01-15-privatepreview' = [for i in range(0, l2DomainCount): {
  name: l2DomainsName[i]
  location: location
  dependsOn: [
    networkFabricProvision
  ]
  properties: {
    networkFabricId: networkFabricsId
    vlanId: l2DomainsProperties[i].properties.vlanId
    mtu: l2DomainsProperties[i].properties.mtu
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
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az nf l2domain update-admin-state --resource-name "${l2DomainsName[i]}" --resource-group ${resourceGroup().name} --state "Enable"'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}]

module isd './ISD.bicep' = [for i in range(0, l3DomainCount): {
  name: 'isd-${i}'
  dependsOn: [
    networkFabricProvision
  ]
  params: {
    l3DomainName: l3DomainsName[i]
    ISDList: ISD
    index: i
    fabricId: networkFabricsId
  }
}]

resource l3DomainUpdateAdminState 'Microsoft.Resources/deploymentScripts@2020-10-01' = [for i in range(0, l3DomainCount): {
  name: '${deploymentScriptsName}-L3UAS-${i}'
  location: location
  dependsOn: [
    isd
  ]
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    scriptContent: 'az extension add --source ${wheelFileURL} -y; az nf l3domain update-admin-state --resource-name "${l3DomainsName[i]}" --resource-group ${resourceGroup().name} --state "Enable"'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
  }
}]
