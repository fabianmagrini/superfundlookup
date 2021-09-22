@description('Storage account name.')
param storageAccountName string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

@description('Table name.')
param tableName string = 'superfund'

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2019-06-01' = {
  name: '${storageaccount.name}/default/${tableName}'
}

output storageAccountName string = storageAccountName
output tableStorageId string = table.id
