@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'superfund'
}

@description('Environment name.')
param environment string = 'prod'

@description('Environment location.')
param location string = resourceGroup().location

// Resource: Keyvault
module keyvault './keyvault.bicep' = {
  name: 'keyvaultModule'
  params: {
    environment: environment
    location: location
    resourceTags: resourceTags
  }
}

@description('Storage container name.')
param containerName string = 'superfund'

// Resource: Storage Account
module storage './storage.bicep' = {
  name: 'storageModule'
  params: {
    environment: environment
    location: location
    containerName: containerName
    resourceTags: resourceTags
  }
}

// Resource: Table Storage
module tablestorage './tablestorage.bicep' = {
  name: 'tablestorageModule'
  params: {
    storageAccountName: storage.outputs.storageAccountName
  }
}

output keyVaultUri string = keyvault.outputs.keyVaultUri
output keyVaultSkuName string = keyvault.outputs.keyVaultSkuName
output storageAccountName string = storage.outputs.storageAccountName
