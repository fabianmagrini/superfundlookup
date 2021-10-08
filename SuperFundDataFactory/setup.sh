#!/bin/bash

# Overide settings on the command line
# ARG1 is environmentID
# ARG2 is resourceGroupName
if [ $# -eq 2 ]
then
  environmentID=$1
  resourceGroupName=$2
else
  environmentID=$RANDOM
  resourceGroupName=superfund-rg-$environmentID
fi

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
location=australiaeast
deploymentName=superfund-$environmentID

# Create a resource group
echo "Create resource group $resourceGroupName ..."
az group create \
    --name $resourceGroupName \
    --location $location

# Deploy Foundation Infrastructure
echo "Deploy foundation Bicep template ..."
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "../infrastructure/main.bicep" \
  --parameters "../infrastructure/main.parameters.dev.json"

# Deploy Datafactory Infrastructure
environment=dev

echo "Deploy data factory Bicep template ..."
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "./datafactory.bicep" \
  --parameters "{ \"environment\": { \"value\": \"dev\" } }"