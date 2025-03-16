//Networking file for Deploying Connection to vhub and Vnets
//Names of resources taken AS IS
targetScope='subscription'

param keyVaultName string
param keyVaultResourceGroup string
param keyVaultSubscription string
param vnets object [] = []
param vwan object
param env string = 'main'
param stage string = 'prod'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing =  {
  name: keyVaultName
  scope: resourceGroup(keyVaultSubscription, keyVaultResourceGroup)
}

module connectRemoteVnetVhub '../Modules/VirtualHub/connectRemoteVnet.bicep' = [for i in range(0, length(vnets)): {
  name: 'connect-${vnets[i].vnetName}-to-vhub'
  scope: resourceGroup(vwan.subscriptionID, vwan.resourceGroupName)
  params: {
    remoteResourceGroup: vnets[i].resourceGroupName
    remoteSubscriptionID: vnets[i].subscriptionID
    remoteTenant: vnets[i].tenantID
    remoteVnetName: vnets[i].vnetName
    vhubName: 'vwanhub-${env}-${stage}-${vnets[i].location}-001'
    subscriptionID: vwan.SubscriptionID
    tenantID: vwan.tenantID
    clientID: keyVault.getSecret('clientid-Main')
    clientSecret: keyVault.getSecret('clientsecret-Main')
    connectionName: '${vnets[i].vnetName}-dns-connection' 
    location: vnets[i].location
  }
}]
