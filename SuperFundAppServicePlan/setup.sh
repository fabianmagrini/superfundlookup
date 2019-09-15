#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
export environmentID=$RANDOM
export keyVaultName=SuperFundKV
export containerRegistryName=SuperFundContainerRegistry
export appServicePlanName=SuperFundAppServicePlan
export webappName=superfund$environmentID
export containerImageName=superfundapi:latest

# Set the resource group name and location for your server
export resourceGroupName=superfund-rg-app-$environmentID
export location=australiaeast

# Create a resource group
echo "Creating resource group $resourceGroupName ..."
az group create \
    --name $resourceGroupName \
    --location $location

# Create an Azure Container Registry (if necessary) and sign in
#../SuperFundACR/setup.sh $environmentID $containerRegistryName

# Enable admin on ACR and retrieve credentials
az acr update -n $containerRegistryName --admin-enabled true

ACR_USER=$(az acr credential show --name $containerRegistryName --query username --output tsv)
ACR_PASSWD=$(az acr credential show --name $containerRegistryName --query passwords[0].value --output tsv)
ACR_LOGIN_SERVER=$(az acr show --name $containerRegistryName --query "loginServer" --output tsv)

# Create App Service plan
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku B1 --is-linux

# Create webapp with container
az webapp create --resource-group $resourceGroupName --plan $appServicePlanName --name $webappName \
  --deployment-container-image-name $ACR_LOGIN_SERVER/$containerImageName

# Enable managed idenity on the webapp
az webapp identity assign --name $webappName --resource-group $resourceGroupName
webappPrincipalId=$(az webapp identity show --name $webappName --resource-group $resourceGroupName --query "principalId" --output tsv)

# Grant access to the webapp to keyvault
az keyvault set-policy --name $keyVaultName --object-id $webappPrincipalId --secret-permissions get list

# Configure registry credentials in webapp
az webapp config container set --name $webappName --resource-group $resourceGroupName \
--docker-custom-image-name $ACR_LOGIN_SERVER/$containerImageName \
--docker-registry-server-url https://$ACR_LOGIN_SERVER \
--docker-registry-server-user $ACR_USER \
--docker-registry-server-password $ACR_PASSWD 

# Configure environment variables (if required)
#az webapp config appsettings set --resource-group $resourceGroupName --name $webappName --settings WEBSITES_PORT=8000

echo "environmentID: $environmentID"
echo "resourceGroupName: $resourceGroupName"
echo "keyVaultName: $keyVaultName"
echo "containerRegistryName: $containerRegistryName"
echo "appServicePlanName: $appServicePlanName"
echo "webappName: $webappName"
echo "containerImageName: $containerImageName"
