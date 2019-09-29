#!/bin/bash

# Overide settings on the command line
# ARG1 is environmentID
# ARG2 is resourceGroupName
# ARG3 is containerRegistryName 
# ARG4 is keyVaultName 
if [ $# -eq 4 ]
then
  environmentID=$1
  resourceGroupName=$2
  containerRegistryName=$3
  keyVaultName=$4
else
  environmentID=$RANDOM
  resourceGroupName=superfund-rg-acr-$environmentID
  containerRegistryName=superfundacr$environmentID
  keyVaultName=superfundkv$environmentID
fi

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
servicePrincipleName=superfund-acr-sp-$environmentID
location=australiaeast

# Create a resource group
echo "Create resource group $resourceGroupName ..."
az group create \
    --name $resourceGroupName \
    --location $location

# Create container registry
echo "Create container registry $containerRegistryName ..."
az acr create --resource-group $resourceGroupName --name $containerRegistryName --sku Basic
az acr login --name $containerRegistryName
az acr repository list --name $containerRegistryName --output table

# Create keyvault if it does not exist
az keyvault show --name $keyVaultName &> /dev/null
if [ $? -ne 0 ]
then
  echo "Create key vault $keyVaultName ..."
  az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location $location
fi

# Wait 15 seconds to make sure that resources have propagated
echo "Waiting for resources to propagate ..."
sleep 15

# Obtain the full registry ID for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $containerRegistryName --query id --output tsv)

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
echo "Create service principal scoped to registry ..."
SP_PASSWD=$(az ad sp create-for-rbac --name http://$servicePrincipleName --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$servicePrincipleName --query appId --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
#echo "Service principal ID: $SP_APP_ID"
#echo "Service principal password: $SP_PASSWD"

# Wait 15 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate ..."
sleep 15

# store its password in AKV (the registry *password*)
echo "store its password in AKV ..."
az keyvault secret set \
  --vault-name $keyVaultName \
  --name $servicePrincipleName-pwd \
  --value $SP_PASSWD

## Store service principal ID in AKV (the registry *username*)
echo "store its ID in AKV ..."
az keyvault secret set \
    --vault-name $keyVaultName \
    --name $servicePrincipleName-usr \
    --value $SP_APP_ID

export ACR_LOGIN_SERVER=$(az acr show --name $containerRegistryName --resource-group $resourceGroupName --query "loginServer" --output tsv)


echo "environmentID: $environmentID"
echo "resourceGroupName: $resourceGroupName"
echo "containerRegistryName: $containerRegistryName"
echo "ACR_LOGIN_SERVER: $ACR_LOGIN_SERVER"
echo "keyVaultName: $keyVaultName"
echo "KV secret name for username: $servicePrincipleName-usr"
echo "KV secret name for password: $servicePrincipleName-pwd"