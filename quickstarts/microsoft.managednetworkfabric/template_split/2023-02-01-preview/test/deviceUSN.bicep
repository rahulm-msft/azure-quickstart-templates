param deviceName string = 'rahul-nf030823-CompRack2-MgmtSwitch'
param location string = resourceGroup().location
param serialNumber string = 'assdfghjklakdhdkl'
param sku string = 'DefaultSku'
param role string = 'MgmtSwitch'

resource USN 'Microsoft.ManagedNetworkFabric/networkDevices@2023-02-01-preview' = {
  name: deviceName
  location: location
  properties: {
    serialNumber: serialNumber
    networkDeviceSku: sku
    networkDeviceRole: role
  }
}
