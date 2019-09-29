# SuperFund Data Factory

Azure Data Factory

References:

* <https://docs.microsoft.com/en-us/azure/data-factory/quickstart-create-data-factory-resource-manager-template>
* <https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy-cli>

## Run deployment

```sh
chmod 775 setup.sh
./setup.sh
```

## Validate template

```sh
location=australiaeast
az deployment validate --location $location --template-file arm_template.json --parameters @arm_template_parameters.json
```

## Deploy template

```sh
resourceGroupName=<resource group>
az group deployment create --resource-group $resourceGroupName --template-file arm_template.json --parameters @arm_template_parameters.json
```

## Load test data

<https://github.com/fabianmagrini/df-demo>
