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

```sh
chmod 775 setup.sh
./setup.sh
```

### Clean up deployment

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName --yes --no-wait
```
