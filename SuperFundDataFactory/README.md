# SuperFund Data Factory

Azure Data Factory

References:

* <https://github.com/fabianmagrini/awesome-learn-azure#azure-data-factory>

## Running CLI

### Logging into the Azure CLI

If you have multiple subscriptions then set subscription after completing the login.

```sh
az login
az account list
az account set --subscription="{SubscriptionID}"
```

## Run deployment

Runs the deployment for the foundation infrastructure and this datafactory. All the infrastructure is created in the same resource group.

```sh
chmod 775 setup.sh
./setup.sh
```

### Testing with what-if

```sh
chmod 775 test.sh
./test.sh
```

### Query the outputs of the deployment

```sh
deploymentName=<deployment name>
resourceGroupName=<resource group name>
az deployment group show \
  --name $deploymentName \
  --resource-group $resourceGroupName \
  --query properties.outputs.dataFactoryName.value
```

The --query is a [JMESPath](https://jmespath.org/) query string.

### Clean up deployment

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName --yes --no-wait
```
