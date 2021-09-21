@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'superfund'
}

@description('The prefix for the storage name.')
param storageNamePrefix string = 'prod'

@description('Storage location.')
param location string = resourceGroup().location

@description('Storage container name.')
param containerName string = 'superfund'

var storageAccountName = '${toLower(storageNamePrefix)}${uniqueString(resourceGroup().id)}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  tags: resourceTags
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
