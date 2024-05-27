//Networking file for Deploying RG (optional), multiple VNETs & Subnet in any subscription (No Connection to VHubs)
//Names of resources taken AS IS
param vnets object [] = []

param tags object = {}

targetScope='subscription'
param rgs object [] = []

module rG '../../Modules/Resourcegroup/resourcegroup.bicep' = [for i in range(0, length(rgs)): {
  scope: subscription(rgs[i].subscriptionID)
  name: rgs[i].resourceGroupName
  params: {
    location: rgs[i].location
    name: rgs[i].resourceGroupName
    tags: tags
  }
}]

module virtualnetwork '../../Modules/VirtualNetwork/vnet.bicep' = [for i in range(0, length(vnets)): {
  scope: resourceGroup(vnets[i].subscriptionID, vnets[i].resourceGroupName)
  name: '${vnets[i].vnetName}'
  params: {
    name:  vnets[i].vnetName
    location: vnets[i].location
    tags: tags
    addressPrefixes: vnets[i].addressPrefixes
    subnets: vnets[i].subnets
  }
  dependsOn: [
    rG
  ]
}]
