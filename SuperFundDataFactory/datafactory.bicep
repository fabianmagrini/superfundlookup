@allowed([
  'dev'
  'prod'
])
@description('Environment.')
param environment string = 'prod'

@description('The tags to apply to resources.')
param resourceTags object = {
  Environment: environment
  Project: 'superfund'
}

@description('Storage location.')
param location string = resourceGroup().location

@description('Storage account name.')
param storageAccountName string = 'storage${toLower(environment)}${uniqueString(resourceGroup().id)}'

@description('Name of the blob container in the Azure Storage account.')
param blobContainerName string = 'superfundcontainer'

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
      columnDelimiter: '|'
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

resource convertFixedWidthDataflow 'Microsoft.DataFactory/factories/dataflows@2018-06-01' = {
  parent: dataFactory
  name: 'ConvertFixedWidth'
  properties: {
    annotations:  []
    type: 'MappingDataFlow'
    typeProperties: {
      sources: [
        {
          dataset: {
            referenceName: txtSourceDataSet.name
            type: 'DatasetReference'
          }
          name: 'source1'
        }
      ]
      sinks: [
        {
          dataset: {
            referenceName: csvSinkDataSet.name
            type: 'DatasetReference'
          }
          name: 'sink1'
        }
      ]
      transformations: [
        {
          name: 'DerivedColumn1'
        }
        {
          name: 'Select1'
        }
        {
          name: 'Filter1'
        }
        {
          name: 'SurrogateKey1'
        }
      ]
      script: 'source(output(\n\t\tColumn_1 as string\n\t),\n\tallowSchemaDrift: true,\n\tvalidateSchema: false,\n\tignoreNoFilesFound: false) ~> source1\nsource1 derive(ABN = trim(substring(Column_1,1,12)),\n\t\tFundName = trim(substring(Column_1,13,201)),\n\t\tUSI = trim(substring(Column_1,214,21)),\n\t\tProductName = trim(substring(Column_1,235,201)),\n\t\tContributionRestrictions = trim(substring(Column_1,436,25)),\n\t\tFromDate = trim(substring(Column_1,461,11)),\n\t\tToDate = trim(substring(Column_1,472,11))) ~> DerivedColumn1\nFilter1 select(mapColumn(\n\t\tABN,\n\t\tFundName,\n\t\tUSI,\n\t\tProductName,\n\t\tContributionRestrictions,\n\t\tFromDate,\n\t\tToDate\n\t),\n\tskipDuplicateMapInputs: true,\n\tskipDuplicateMapOutputs: true) ~> Select1\nSurrogateKey1 filter(Key!=2) ~> Filter1\nDerivedColumn1 keyGenerate(output(Key as long),\n\tstartAt: 1L) ~> SurrogateKey1\nSelect1 sink(allowSchemaDrift: true,\n\tvalidateSchema: false,\n\tpartitionFileNames:[\'SflUsiExtract.csv\'],\n\tskipDuplicateMapInputs: true,\n\tskipDuplicateMapOutputs: true,\n\tsaveOrder: 1) ~> sink1'
    }
  }
}

resource fetchSuperfundlookupPipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: 'FetchSuperfundlookup'
  properties: {
    activities: [
      {
        name: 'Copy Data1'
        type: 'Copy'
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
      }
      {
        name: 'Dataflow1'
        type: 'ExecuteDataFlow'
        dependsOn: [
          {
            activity: 'Copy Data1'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        userProperties: []
        typeProperties: {
          dataFlow: {
            referenceName: convertFixedWidthDataflow.name
            type: 'DataFlowReference'
            parameters: {}
            datasetParameters: {
              source1: {}
              sink1: {}
            }
          }
        }
      }
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
