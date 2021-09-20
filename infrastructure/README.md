# Infrastructure Setup

Infra as code using bicep.

## Running CLI

### Logging into the Azure CLI

If you have multiple subscriptions then set subscription after completing the login.

```sh
az login
az account list
az account set --subscription="{SubscriptionID}"
```

### Deploy the Bicep template from local

Added default values to the template when running local.

```sh
environmentID=$RANDOM
deploymentName=superfund-$environmentID
resourceGroupName=superfund-rg-$environmentID
location=australiaeast
az group create -l $location -n $resourceGroupName
az deployment group create \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --template-file "./main.bicep" \
  --parameters "./main.parameters.dev.json"
```

### Clean up deployment

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName --yes --no-wait
```
