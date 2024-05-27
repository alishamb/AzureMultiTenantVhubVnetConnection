targetScope = 'resourceGroup'
metadata name = 'Virtual Networks'
metadata description = 'This module deploys a Virtual Network (vNet).'

@description('Required. The Virtual Network (vNet) Name.')
param name string

@description('Optional. Location for all resources.')
param location string

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

@description('Optional. An Array of subnets to deploy to the Virtual Network.')
param subnets array = []

param tags object = {}
//var purpose = split(name, '-')[1]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [for i in range(0, length(subnets)): {
      name: subnets[i].name //'snet-${purpose}-${subnets[i].name}-${location}-001'
      properties: {
          networkSecurityGroup: (contains(subnets[i], 'nsg')) ? {
            id: '${resourceGroup().id}/providers/Microsoft.Network/networkSecurityGroups/${subnets[i].nsg.name}'
          } : null
          addressPrefix: subnets[i].subnetPrefix
          delegations: contains(subnets[i].name, 'pdr') ? [
              {
                name: 'Microsoft.Network.dnsResolvers'
                properties: {
                  serviceName: 'Microsoft.Network/dnsResolvers'
                }
                type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
              }
          ] : [] 
      }
    }]
  }
  dependsOn: [
    networkSecurityGroup
  ]
}

module networkSecurityGroup '../Networksecuritygroup/inboundNSG.bicep' = [for subnet in subnets: {
  name: 'nsg-${subnet.name}'
  params: {
    location: location
    nsgName: (contains(subnet, 'nsg')) ? subnet.nsg.name : 'nsg'
    subnetName: subnet.name
    //vnetName: name
    securityRules: contains(subnet, 'nsg') ? subnet.nsg.rules : []
    tags: tags
  }
}]



@description('The resource group the virtual network was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network.')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network.')
output name string = virtualNetwork.name

@description('The names of the deployed subnets.')
output subnetNames array = [for subnet in subnets: subnet.name]

@description('The resource IDs of the deployed subnets.')
output subnetResourceIds array = [for subnet in subnets: az.resourceId('Microsoft.Network/virtualNetworks/subnets', name, subnet.name)]

@description('The location the resource was deployed into.')
output location string = virtualNetwork.location

output properties object = virtualNetwork.properties
