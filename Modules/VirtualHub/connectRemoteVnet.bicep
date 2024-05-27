param remoteTenant string
param remoteSubscriptionID string
param remoteResourceGroup string
param remoteVnetName string
param vhubName string
param connectionName string
param subscriptionID string
param tenantID string

@secure()
param clientSecret string
@secure()
param clientID string

param location string = resourceGroup().location

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'connectRemote${remoteVnetName}toVhub'
  location: location
  kind: 'AzureCLI'
  properties: {
    arguments: '${tenantID} ${remoteTenant} ${remoteSubscriptionID} ${subscriptionID} ${remoteResourceGroup} ${remoteVnetName} ${connectionName} ${vhubName}'
    environmentVariables: [
      {
        name: 'parentResourceGroupName'
        value: resourceGroup().name
      }
      {
        name: 'clientID'
        value: clientID
      }
      {
        name: 'clientSecret'
        value: clientSecret
      }
    ]
    azCliVersion: '2.54.0'
    scriptContent: '''
    az login --service-principal -u $clientID -p $clientSecret --tenant $2
    az account set --subscription $3
    az login --service-principal -u $clientID -p $clientSecret --tenant $1
    az account set --subscription $4
    az extension add --name virtual-wan -y --version 0.3.0
    az network vhub connection create --resource-group $parentResourceGroupName --name $7 --vhub-name $8 --remote-vnet "/subscriptions/${3}/resourceGroups/${5}/providers/Microsoft.Network/virtualNetworks/${6}"
    
    '''
    retentionInterval: 'P1D'
  }
}
