
param name string
param virtualRouterAsn int = 65515 
param minRoutingInfrastructureUnit int = 2// minimum value is 2 for Azure Virtual WAN
param routingPreference string

param type string = 'Standard'
param addressSpace string


@description('Optional. Location of the Resource Group.')
param location string
param createSecurevHub bool = false

param virtualWanName string

param publicIpsCount int

resource virtualWan 'Microsoft.Network/virtualWans@2023-04-01' existing = {
  name: virtualWanName
}

resource vWANHub 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: name
  location: location
  properties: {
    addressPrefix: addressSpace
    virtualRouterAsn: virtualRouterAsn
    virtualRouterAutoScaleConfiguration: {
      minCapacity: minRoutingInfrastructureUnit 
    }
    virtualWan: {
      id: virtualWan.id
    }
    sku: type
    hubRoutingPreference: routingPreference
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' = if (createSecurevHub) {
  name: 'afw-${name}'
  location: location
  properties: {
    sku: {
      name: 'AZFW_Hub'
      tier: 'Standard'
    }
    hubIPAddresses: {
      publicIPs: {
        count: publicIpsCount
      }
    }
    virtualHub: {
      id: vWANHub.id
    }
  }
}

output vwanHubid string = vWANHub.id
