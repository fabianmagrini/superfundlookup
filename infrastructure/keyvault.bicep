@allowed([
  'dev'
  'prod'
])
@description('Environment.')
param environment string = 'prod'

@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'superfund'
}

@description('Resource location.')
param location string = resourceGroup().location

var keyVaultName = 'kv${toLower(environment)}${uniqueString(resourceGroup().id)}'
var tenantId = subscription().tenantId

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: resourceTags
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: [
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultSkuName string = keyVault.properties.sku.name
