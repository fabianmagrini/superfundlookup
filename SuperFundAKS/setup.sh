#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Set the AKS cluster name
clusterName=SuperFundAKSCluster

# Set the resource group name and location for your server
resourceGroupName=superfund-rg-aks-$RANDOM
location=australiaeast

# Create a resource group
az group create \
    --name $resourceGroupName \
    --location $location

# Create AKS cluster
az aks create \
    --resource-group $resourceGroupName \
    --name $clusterName \
    --node-count 1 \
    --enable-addons monitoring \
    --generate-ssh-keys