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

// Resource: Storage Account
module storage './storage.bicep' = {
  name: 'storageModule'
  params: {
    storageNamePrefix: storageNamePrefix
    location: location
    containerName: containerName
    resourceTags: resourceTags
  }
}

output storageAccountNameOutput string = storage.outputs.storageAccountNameOutput
