#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment
export environmentID=$RANDOM
export keyVaultName=SuperFundKV
export containerRegistryName=SuperFundContainerRegistry
export servicePrincipleName=superfund-aks-sp-$environmentID
export clusterName=SuperFundAKSCluster

# Set the resource group name and location for your server
export resourceGroupName=superfund-rg-aks-$environmentID
export location=australiaeast

# Create a resource group
echo "Creating resource group $resourceGroupName ..."
az group create \
    --name $resourceGroupName \
    --location $location

# Create a service principal
echo "Creating service principal $servicePrincipleName ..."
SP_PASSWD=$(az ad sp create-for-rbac --name http://$servicePrincipleName --skip-assignment --query password --output tsv)
SP_APP_ID=$(az ad sp show --id http://$servicePrincipleName --query appId --output tsv)
echo "SP_APP_ID: $SP_APP_ID created."

# Wait 15 seconds to make sure that service principal has propagated
echo "Waiting for service principal to propagate ..."
sleep 15

# Obtain the full registry ID for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $containerRegistryName --query id --output tsv)

# Configure ACR authentication
echo "Assign SP_APP_ID: $SP_APP_ID access to $ACR_REGISTRY_ID"
az role assignment create --assignee $SP_APP_ID --scope $ACR_REGISTRY_ID --role acrpull

# Create AKS cluster
echo "Creating AKS Cluster $clusterName in $resourceGroupName with SP $SP_APP_ID ..."
az aks create \
    --resource-group $resourceGroupName \
    --name $clusterName \
    --node-count 1 \
    --enable-addons monitoring \
    --service-principal $SP_APP_ID \
    --client-secret $SP_PASSWD \
    --generate-ssh-keys

# Setup Flexvol for mounting secrets from Azure Key Vault into Pods within AKS
echo "setup Flexvol ..."

# Download credentials and configures kubectl
az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing

# install flexvol
kubectl create -f https://raw.githubusercontent.com/Azure/kubernetes-keyvault-flexvol/master/deployment/kv-flexvol-installer.yaml

# Add your service principal credentials as Kubernetes secrets accessible by the Key Vault FlexVolume driver.
kubectl create secret generic kvcreds --from-literal clientid=$SP_APP_ID --from-literal clientsecret=$SP_PASSWD --type=azure/kv

# Assign Reader Role to the service principal for your keyvault
keyVaultID=$(az keyvault show --name $keyVaultName --query id --output tsv)

az role assignment create --role Reader --assignee $SP_APP_ID --scope $keyVaultID

az keyvault set-policy -n $keyVaultName --key-permissions get --spn $SP_APP_ID
az keyvault set-policy -n $keyVaultName --secret-permissions get --spn $SP_APP_ID
az keyvault set-policy -n $keyVaultName --certificate-permissions get --spn $SP_APP_ID

echo "environmentID: $environmentID"
echo "resourceGroupName: $resourceGroupName"
echo "containerRegistryName: $containerRegistryName"
echo "clusterName: $clusterName"
echo "keyVaultName: $keyVaultName"
echo "servicePrincipleName: $servicePrincipleName"


