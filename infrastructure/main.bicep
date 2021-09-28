@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'superfund'
}

@description('Environment name.')
param environment string = 'prod'

@description('Environment location.')
param location string = resourceGroup().location

@description('Name of the Key Vault.')
param keyVaultName string = 'keyvault${toLower(environment)}${uniqueString(resourceGroup().id)}'

module keyvault './keyvault.bicep' = {
  name: 'keyvaultModule'
  params: {
    environment: environment
    location: location
    keyVaultName: keyVaultName
    resourceTags: resourceTags
  }
}

@description('Name of the storage account.')
param storageAccountName string = 'storage${toLower(environment)}${uniqueString(resourceGroup().id)}'

@description('Name of the blob container in the Storage account.')
param blobContainerName string = 'blob${toLower(environment)}${uniqueString(resourceGroup().id)}'

module storage './storage.bicep' = {
  name: 'storageModule'
  params: {
    environment: environment
    location: location
    storageAccountName: storageAccountName
    blobContainerName: blobContainerName
    resourceTags: resourceTags
  }
}

module tablestorage './tablestorage.bicep' = {
  name: 'tablestorageModule'
  params: {
    storageAccountName: storage.outputs.storageAccountName
  }
}

@description('Name of the Datafactory.')
param dataFactoryName string = 'datafactory${toLower(environment)}${uniqueString(resourceGroup().id)}'

module datafactory './datafactory.bicep' = {
  name: 'datafactoryModule'
  params: {
    environment: environment
    location: location
    storageAccountName: storage.outputs.storageAccountName
    blobContainerName: blobContainerName
    dataFactoryName: dataFactoryName
    resourceTags: resourceTags
  }
}


output keyVaultUri string = keyvault.outputs.keyVaultUri
output keyVaultSkuName string = keyvault.outputs.keyVaultSkuName
output storageAccountName string = storage.outputs.storageAccountName
