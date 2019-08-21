#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Set the resource group name and location for your server
suffixId=$RANDOM
location=australiaeast
eventHubNamespace=superfund-eh-$suffixId
eventHubName=superfund

# Create a resource group (if necessary)
resourceGroupName=superfund-rg-$suffixId
az group create --name $resourceGroupName --location australiaeast

# Create an Event Hubs namespace
az eventhubs namespace create --name $eventHubNamespace --resource-group $resourceGroupName -l $location

# Create an event hub
az eventhubs eventhub create --name $eventHubName --resource-group $resourceGroupName --namespace-name $eventHubNamespace --message-retention 1 --partition-count 2

# Get the connection string
az eventhubs namespace authorization-rule keys list --resource-group $resourceGroupName --namespace-name $eventHubNamespace --name RootManageSharedAccessKey
