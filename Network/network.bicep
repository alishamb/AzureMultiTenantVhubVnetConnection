targetScope='subscription'

param createVWAN bool = false
@description('Optional. True if branch to branch traffic is allowed.')
param allowBranchToBranchTraffic bool = false
@description('Optional. True if VNET to VNET traffic is allowed.')
param allowVnetToVnetTraffic bool = true
@description('Optional. VPN  encryption to be disabled or not.')
param disableVpnEncryption bool = false
param type string = 'Standard'
@description('Optional. Tags for VWAN.')
param tags object = {}
param vwan object = {}
param vWANhubs object [] = []
param vnet object = {}
param createVnet bool = false
param createHubVirtualNetworkConnection bool = false
param env string = 'main'
param purpose string = 'dns'
param stage string = 'prod'
param rgs object [] = []

module rG '../Modules/Resourcegroup/resourcegroup.bicep' = [for i in range(0, length(rgs)): {
  scope: subscription(rgs[i].subscriptionID)
  name: rgs[i].resourceGroupName
  params: {
    location: rgs[i].location
    name: rgs[i].resourceGroupName
    tags: tags
  }
}]

module virtualnetwork '../Modules/VirtualNetwork/vnet.bicep' = if (createVnet) {
  name: 'VirtualNetwork'
  scope: resourceGroup(vnet.subscriptionID, vnet.resourceGroupName)
  params: {
    name:  'vnet-${purpose}-network-${vnet.location}-001'
    location: vnet.location
    tags: tags
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
  }
  dependsOn: [
    rG
  ]
}

module vWan '../Modules/VirtualWAN/vwan.bicep' = if (createVWAN){
  name: 'vwan-${env}-${stage}-${vwan.location}' 
  scope: resourceGroup(vwan.subscriptionID, vwan.resourceGroupName)
  params: {
    name: 'vwan-${env}-${stage}-${vwan.location}'
    location: vwan.location
    tags: tags
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic ? allowVnetToVnetTraffic : null
    disableVpnEncryption: disableVpnEncryption
    type: type 
  }
  dependsOn: [
    rG
  ]
}

module vwanHub '../Modules/VirtualHub/virtualHub.bicep' = [for i in range(0, length(vWANhubs)): {
  name: 'vwanhub-${env}-${stage}-${vWANhubs[i].location}-001'
  scope: resourceGroup(vwan.subscriptionID, vwan.resourceGroupName)
  params: {
    name: 'vwanhub-${env}-${stage}-${vWANhubs[i].location}-001'
    virtualWanName: 'vwan-${env}-${stage}-${vwan.location}'
    virtualRouterAsn: vWANhubs[i].virtualRouterAsn
    minRoutingInfrastructureUnit: vWANhubs[i].minRoutingInfrastructureUnit
    addressSpace: vWANhubs[i].addressSpace
    location: vWANhubs[i].location
    routingPreference: vWANhubs[i].routingPreference
    publicIpsCount: vWANhubs[i].publicIpsCount
    createSecurevHub: vWANhubs[i].createSecurevHub
  }
  dependsOn: [
    vWan
  ]
}]

module connectVnetHub '../Modules/VirtualHub/connectVnet.bicep' = if (createHubVirtualNetworkConnection){
  name: 'connect-vnet-to-hub'
  scope: resourceGroup(vwan.subscriptionID, vwan.resourceGroupName)
  params: {
    vhubName: 'vwanhub-${env}-${stage}-${vnet.location}-001'
    virtualNetworkID: (createVnet) ? virtualnetwork.outputs.resourceId : vnet.id
    connectionName: '${purpose}-vnet-${env}'
  }
  dependsOn: [
    vWan
    vwanHub
    virtualnetwork
  ]
}
