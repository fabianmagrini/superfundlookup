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
  resourceGroupName=superfund-rg-df-$environmentID
fi

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
location=australiaeast

# Create a resource group
echo "Create resource group $resourceGroupName ..."
az group create \
    --name $resourceGroupName \
    --location $location

# Deploy ARM template
echo "Deploy data factory ARM template ..."
az group deployment create --resource-group $resourceGroupName --template-file arm_template.json --parameters @arm_template_parameters.json
