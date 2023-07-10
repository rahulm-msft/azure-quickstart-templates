param location string = resourceGroup().location

// param wheelFileURL string = 'https://k4pvsblobprodwus2140.vsblob.vsassets.io/b-c0cf4e79286048b9a5f40ffff4167045/975D6A5168A4BD6EA480A992A7C829A26492202D3EA8F6EC3E862E65998B442E00.blob?sv=2019-07-07&sr=b&si=1&sig=EV7RhOcX42qYVUGHsS1dbt1WSdY9gOAQ7QDT4Y%2FZN9A%3D&spr=https&se=2023-03-09T05%3A47%3A02Z&rscl=x-e2eid-0d84c720-0d244af8-a6ee10df-daf50e28-session-0d84c720-0d244af8-a6ee10df-daf50e28&rscd=attachment%3B%20filename%3D%22managednetworkfabric-0.1.0.post31-py3-none-any.whl%22&P1=1678351620&P2=1&P3=2&P4=Gqx8Bjzq7Cdc%2f%2f9QQIWx47sDhYRZTSXA3KqmghdyTkM%3d'

param wheelFileURL string = 'https://nfadevstorage.blob.core.windows.net/mnfazcliwhl/managednetworkfabric-0.1.0.post31-py3-none-any.whl'

param userIdentityName string = 'userIdentityName1'

param roleId string = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'

param roleDefinitionId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleId}'

param roleAssignmentName string = guid(userIdentityName, roleDefinitionId, resourceGroup().id)

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userIdentityName
  location: location
}

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  //name: '543205c7-9956-4f49-9973-be82d340ce16' //'e2e04f27-bd4d-4eb6-b382-f086391ad3b3'
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: userIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource updateSerialNumber 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'testWheelFileInstall'
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
    scriptContent: loadTextContent('install.sh')
    //scriptContent: 'echo "start"; sleep 1m; echo "end"'
    azCliVersion: '2.42.0'
    retentionInterval: 'PT4H'
    // environmentVariables: [
    //   {
    //     name: 'WHEEL_FILE_URL'
    //     value: wheelFileURL
    //   }
    // ]
  }
}

output roleAssName string = roleAssignmentName
output roleDefId string = roleDefinitionId
output principleId string = userIdentity.properties.principalId
