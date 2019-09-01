# SuperFund Base Environment

Setup the base environment

References:

<https://docs.microsoft.com/en-us/azure/key-vault/key-vault-manage-with-cli2>
<https://docs.microsoft.com/bs-latn-ba/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest>

## Run deployment

```sh
chmod 775 setup.sh
./setup.sh
```

## Clean up deployment

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName --yes --no-wait
```
