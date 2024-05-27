
param vhubName string
param virtualNetworkID string
param connectionName string

resource vhub 'Microsoft.Network/virtualHubs@2023-04-01' existing = {
  name: vhubName
}

resource connectVnet 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2023-04-01' = {
  name: connectionName
  parent: vhub
  properties: {
    remoteVirtualNetwork: {
      id: virtualNetworkID
    }
  }
}
