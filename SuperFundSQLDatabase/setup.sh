#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Set the database name
databasename=SuperFundSQLDB

# Set the resource group name and location for your server
resourceGroupName=superfund-rg-sql-$RANDOM
location=australiaeast

# Set an admin login and password for your database
adminlogin=ServerAdmin
password=`openssl rand -base64 16`
# password=<EnterYourComplexPasswordHere1>

# The logical server name has to be unique in the system
servername=superfund-server-$RANDOM

# The ip address range that you want to allow to access your DB
startip=0.0.0.0
endip=0.0.0.0

# Create a resource group
az group create \
    --name $resourceGroupName \
    --location $location

# Create a logical server in the resource group
az sql server create \
    --name $servername \
    --resource-group $resourceGroupName \
    --location $location  \
    --admin-user $adminlogin \
    --admin-password $password

# Configure a firewall rule for the server
az sql server firewall-rule create \
    --resource-group $resourceGroupName \
    --server $servername \
    -n AllowYourIp \
    --start-ip-address $startip \
    --end-ip-address $endip

# Create a database in the server with zone redundancy as false
az sql db create \
    --resource-group $resourceGroupName \
    --server $servername \
    --name $databasename \
    --edition GeneralPurpose \
    --family Gen5 \
    --capacity 1 \
    --zone-redundant false

# Zone redundancy is only supported in the premium and business critical service tiers

# Echo random password
echo $password