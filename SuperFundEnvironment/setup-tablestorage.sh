#!/bin/bash

# Overide settings on the command line
# ARG1 is resourceGroupName
if [ $# -eq 0 ]
then
  environmentID=$RANDOM
  resourceGroupName=superfund-rg-ts-$environmentID
else
  environmentID=""
  resourceGroupName=$1
fi

# Set the location for your services
location=australiaeast

# Create a resource group if it does not exist
if [ $(az group exists --name $resourceGroupName) = false ]
then
  az group create \
  --name $resourceGroupName \
  --location $location
fi

# create storage account
export AZURE_STORAGE_ACCOUNT=superfundstorage$environmentID
az storage account create \
    --name $AZURE_STORAGE_ACCOUNT \
    --resource-group $resourceGroupName \
    --location $location \
    --sku Standard_LRS

export AZURE_STORAGE_KEY=$(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT --resource-group $resourceGroupName --query [0].value --output tsv)

# create Table Storage
storageTableName=SuperfundTable$environmentID
az storage table create --name $storageTableName
