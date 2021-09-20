param storageNamePrefix string = 'STG'
param containerName string = 'superfund'
param location string = resourceGroup().location

var storageAccountName = '${toLower(storageNamePrefix)}${uniqueString(resourceGroup().id)}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageaccount.name}/default/${containerName}'
}

output storageAccountNameOutput string = storageAccountName
