#!/bin/bash

# Overide settings on the command line
# ARG1 is resourceGroupName
# ARG2 is keyVaultName
if [ $# -eq 0 ]
then
  environmentID=$RANDOM
  resourceGroupName=superfund-rg-$environmentID
  keyVaultName=superfundkv$environmentID
else
  environmentID=""
  resourceGroupName=$1
  keyVaultName=$2
fi

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment
location=australiaeast

# Create a resource group if it does not exist
if [ $(az group exists --name $resourceGroupName) = false ]
then
  echo "Create resource group $resourceGroupName ..."
  az group create \
  --name $resourceGroupName \
  --location $location
fi

# Create keyvault if it does not exist
az keyvault show --name $keyVaultName &> /dev/null
if [ $? -ne 0 ]
then
  echo "Create key vault $keyVaultName ..."
  az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location $location
fi

# Create the blob storage
./setup-blobstorage.sh $resourceGroupName $environmentID
./setup-tablestorage.sh $resourceGroupName $environmentID

echo "environmentID: $environmentID"
echo "resourceGroupName=: $resourceGroupName"
echo "keyVaultName: $keyVaultName"