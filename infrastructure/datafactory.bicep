@allowed([
  'dev'
  'prod'
])
@description('Environment.')
param environment string = 'prod'

@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: 'prod'
  Project: 'template'
}

@description('Storage location.')
param location string = resourceGroup().location

@description('Storage account name.')
param storageAccountName string

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string

@description('Name of the Datafactory.')
param dataFactoryName string = 'datafactory${toLower(environment)}${uniqueString(resourceGroup().id)}'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01'  existing = {
  name: blobContainerName
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: dataFactoryName
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {}
}

resource superfundlookupLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'SuperfundlookupLinkedService'
  properties: {
    type: 'HttpServer'
    typeProperties: {
      url: 'http://superfundlookup.gov.au/Tools/DownloadUsiList?download=true'
      authenticationType: 'Anonymous'
    }
  }
}

resource blobStorageLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'StorageLinkedService'
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'
    }
  }
}

resource tableStorageLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'TableStorageLinkedService'
  properties: {
    type: 'AzureTableStorage'
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${storageaccount.listKeys().keys[0].value}'
    }
  }
}

resource superfundlookupDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SuperfundlookupService'
  properties: {
    linkedServiceName: {
      referenceName: superfundlookupLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'Binary'
    typeProperties:{  
      location: {
        type: 'HttpServerLocation'
      }
    }
  }
}

resource txtDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SflUsiExtractTxt'
  properties: {
    linkedServiceName: {
      referenceName: blobStorageLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureBlob'
    typeProperties: {
      fileName: 'SflUsiExtract.txt'
      folderPath: 'superfundcontainer'
    }
  }
}


resource txtSourceDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SflUsiExtractTxtSource'
  properties: {
    linkedServiceName: {
      referenceName: blobStorageLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'DelimitedText'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        fileName: 'SflUsiExtract.txt'
        container: 'superfundcontainer'
      }
      columnDelimiter: ''
      escapeChar: '\\'
      firstRowAsHeader: false
      quoteChar: '"'
    }
  }
}

resource csvSinkDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SflUsiExtractCsvSink'
  properties: {
    linkedServiceName: {
      referenceName: blobStorageLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'DelimitedText'
    typeProperties: {
      location: {
        type: 'AzureBlobStorageLocation'
        container: 'superfundcontainer'
      }
      columnDelimiter: ','
      escapeChar: '\\'
      quoteChar: '"'
    }
  }
}

resource csvDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SflUsiExtractCsv'
  properties: {
    linkedServiceName: {
      referenceName: blobStorageLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureBlob'
    structure: [
      {
        name: 'ABN'
        type: 'String'
      }
      {
        name: 'FundName'
        type: 'String'
      }
      {
        name: 'USI'
        type: 'String'
      }
      {
        name: 'ProductName'
        type: 'String'
      }
      {
        name: 'ContributionRestrictions'
        type: 'String'
      }
      {
        name: 'From'
        type: 'String'
      }
      {
        name: 'To'
        type: 'String'
      }
    ]
    typeProperties: {
      format: {
        type: 'TextFormat'
        columnDelimiter: '|'
        rowDelimiter: '\n'
        quoteChar: '"'
        nullValue: '\\N'
        encodingName: null
        treatEmptyAsNull: true
        skipLineCount: 0
        firstRowAsHeader: true
      }
      fileName: 'SflUsiExtract.csv'
      folderPath: 'superfundcontainer'
    }
  }
}

resource tableDataSet 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: 'SuperfundTable'
  properties: {
    linkedServiceName: {
      referenceName: tableStorageLinkedService.name
      type: 'LinkedServiceReference'
    }
    annotations: []
    type: 'AzureTable'
    schema: []
    typeProperties: {
      tableName: 'SuperfundTable'
    }
  }
}

resource fetchSuperfundlookupPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: 'FetchSuperfundlookup'
  properties: {
    activities: [
      any({
        name: 'Copy Data1'
        type: 'Copy'
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'BinarySource'
            storeSettings: {
              type: 'HttpReadSettings'
              requestMethod: 'GET'
            }
            formatSettings: {
                type: 'BinaryReadSettings'
            }
          }
          sink: {
            type: 'BlobSink'
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: superfundlookupDataSet.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
        outputs: [
          {
            referenceName: txtDataSet.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
      })
    ]
  }
}

resource loadTablePipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: 'LoadTable'
  properties: {
    activities: [
      any({
        name: 'Copy Data1'
        type: 'Copy'
        policy: {
          timeout: '7.00:00:00'
          retry: 0
          retryIntervalInSeconds: 30
          secureOutput: false
          secureInput: false
        }
        userProperties: []
        typeProperties: {
          source: {
            type: 'BlobSource'
            recursive: true
          }
          sink: {
            type: 'AzureTableSink'
            azureTableInsertType: 'merge'
            writeBatchSize: 10000
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: csvDataSet.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
        outputs: [
          {
            referenceName: tableDataSet.name
            type: 'DatasetReference'
            parameters: {}
          }
        ]
      })
    ]
  }
}

output dataFactoryName string = dataFactory.name
