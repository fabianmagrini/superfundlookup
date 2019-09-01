#!/bin/bash

# Overide settings on the command line
# ARG1 is environmentID
# ARG2 is containerRegistryName (optional)
if [ $# -eq 0 ]
then
  environmentID=$RANDOM
  containerRegistryName=SuperFundContainerRegistry
else
  environmentID=$1
  if [ $# -eq 1 ]
  then
    containerRegistryName=SuperFundContainerRegistry
  else
    containerRegistryName=$2
  fi
fi

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
keyVaultName=SuperFundKV
servicePrincipleName=superfund-acr-sp-$environmentID

# Set the resource group name and location for your server
resourceGroupName=superfund-rg-acr-$environmentID
location=australiaeast

# Create a resource group
az group create \
    --name $resourceGroupName \
    --location $location

# Create container registry
az acr create --resource-group $resourceGroupName --name $containerRegistryName --sku Basic
az acr login --name $containerRegistryName
az acr repository list --name $containerRegistryName --output table

# Create keyvault if it does not exist
az keyvault show --name $keyVaultName &> /dev/null
if [ $? -ne 0 ]
then
  az keyvault create --name $keyVaultName --resource-group $resourceGroupName --location $location
fi

# Obtain the full registry ID for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $containerRegistryName --query id --output tsv)

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
SP_PASSWD=$(az ad sp create-for-rbac --name http://$servicePrincipleName --scopes $ACR_REGISTRY_ID --role acrpull --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$servicePrincipleName --query appId --output tsv)

# Output the service principal's credentials; use these in your services and
# applications to authenticate to the container registry.
#echo "Service principal ID: $SP_APP_ID"
#echo "Service principal password: $SP_PASSWD"

# store its password in AKV (the registry *password*)
az keyvault secret set \
  --vault-name $keyVaultName \
  --name $servicePrincipleName-pwd \
  --value $SP_PASSWD

## Store service principal ID in AKV (the registry *username*)
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