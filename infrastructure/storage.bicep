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

@description('Storage location.')
param location string = resourceGroup().location

@description('Storage container name.')
param containerName string = 'superfund'

var storageAccountName = 'sa${toLower(environment)}${uniqueString(resourceGroup().id)}'

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

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: '${storageaccount.name}/default/${containerName}'
}

output storageAccountName string = storageAccountName
