@description('Required. The name of the VWAN.')
param name string

@description('Optional. Location of the Resource Group.')
param location string

@description('Optional. The type of the Virtual WAN.')
@allowed([
  'Standard'
  'Basic'
])
param type string = 'Standard'

@description('Optional. True if branch to branch traffic is allowed.')
param allowBranchToBranchTraffic bool = false

@description('Optional. True if VNET to VNET traffic is allowed.')
param allowVnetToVnetTraffic bool = true

@description('Optional. VPN encryption to be disabled or not.')
param disableVpnEncryption bool = false

@description('Optional. Tags for VWAN.')
param tags object = {}

resource virtualWan 'Microsoft.Network/virtualWans@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic ? allowVnetToVnetTraffic : null
    disableVpnEncryption: disableVpnEncryption
    type: type
  }
}

@description('The name of the virtual WAN.')
output name string = virtualWan.name

@description('The resource ID of the virtual WAN.')
output resourceId string = virtualWan.id

@description('The resource group the virtual WAN was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = virtualWan.location
