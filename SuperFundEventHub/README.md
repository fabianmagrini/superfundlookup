# Setup Azure Event Hub

References:
<https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-quickstart-cli>

## Run deployment

```sh
chmod 775 setup.sh
./setup.sh
```

## Clean up deployment

When you created a unique resource group for the Event Hub resources

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName
```
