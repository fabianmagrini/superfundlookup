@allowed([
  'dev'
  'prod'
])
@description('Environment.')
param environment string = 'prod'

var environmentSettings = {
  dev: {
    storageAccountSku: 'Standard_LRS'
  }
  prod: {
    storageAccountSku: 'Standard_LRS'
  }
}

@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'superfund'
}

@description('Storage account location.')
param location string = resourceGroup().location

@description('Name of the storage account.')
param storageAccountName string = 'superfund'

@description('Name of the blob container in the Storage account.')
param blobContainerName string = 'superfund'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  tags: resourceTags
  sku: {
    name: environmentSettings[environment].storageAccountSku
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageaccount.name}/default/${blobContainerName}'
}

output storageAccountName string = storageAccountName
output blobContainerName string = blobContainerName
