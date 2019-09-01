#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
keyVaultName=SuperFundKV

# Set the resource group name and location for your server
resourceGroupName=SuperfundLookupRG
location=australiaeast

# Create a resource group if it does not exist
if [ $(az group exists --name $resourceGroupName) = false ]
then
  az group create \
  --name $resourceGroupName \
  --location $location
fi

# Create keyvault if it does not exist
az keyvault show --name $keyVaultName &> /dev/null
if [ $? -ne 0 ]
then
  az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location $location
fi