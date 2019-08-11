# SuperFund Azure Functions

Trigger Azure Function from Event Hub 

References:

<https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function-azure-cli>
<https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-event-hubs#trigger---c-example>

## Prerequisites

## Install the Azure Functions Core Tools

<https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local#v2>

## Create a function app in Azure

```sh
functionAppName=superFundFunction
resourceGroup=superFundFunction

az functionapp create --resource-group $resourceGroup --consumption-plan-location australiaeast \
--name $functionAppName --storage-account  <STORAGE_NAME> --runtime <language>
```

## Create a local Functions project

```sh
func init SuperFundFunction
cd SuperFundFunction
```

### Register Azure Functions binding extensions

To enable extension bundles, open the host.json file and update its contents to match the following code:

```json
{
    "version": "2.0",
    "extensionBundle": {
        "id": "Microsoft.Azure.Functions.ExtensionBundle",
        "version": "[1.*, 2.0.0)"
    }
}
```

```sh
func extensions install
```

### Get your storage connection strings
```sh
func azure functionapp fetch-app-settings <FunctionAppName>
```

## Create a function
```sh
func new
```
## Run functions locally
```sh
func host start --build
```

## Getting Key Vault Secrets in Azure Functions

References:
<https://medium.com/statuscode/getting-key-vault-secrets-in-azure-functions-37620fd20a0b>

### Set secret
```sh
az keyvault secret set --vault-name SuperFundKV -n EventHubConnectionString --value '...'
```

### Assign Managed Identity to Function App
```sh
functionAppName=superFundFunction
resourceGroup=superFundFunction

az functionapp identity assign -n $functionAppName -g $resourceGroup

principalId=$(az functionapp identity show -n $functionAppName -g $resourceGroup --query principalId -o tsv)
tenantId=$(az functionapp identity show -n $functionAppName -g $resourceGroup --query tenantId -o tsv)
```

### find the service principal in AD:
```sh
az ad sp show --id $principalId
az ad sp list --display-name $functionAppName
```

### List appsettings
n.b. there are two new environment variables MSI_ENDPOINT, MSI_SECRET but they are not visible as appsettings
```sh
az functionapp config appsettings list -n $functionAppName -g $resourceGroup -o table
```

### Secret Id
```sh
keyvaultname=superfundkv
secretName=EventHubConnectionString

secretId=$(az keyvault secret show -n $secretName --vault-name $keyvaultname --query "id" -o tsv)
```

### grant the function app permissions to access the key vault
```sh
az keyvault set-policy -n $keyvaultname -g $resourceGroup --object-id $principalId --secret-permissions get list
```

### Set appsetting
```sh
functionAppName=superFundFunction
resourceGroup=superFundFunction
az functionapp config appsettings set --name $functionAppName --resource-group $resourceGroup --settings "EventHubConnectionString=@Microsoft.KeyVault(SecretUri=<SecretUri>)"
```

## Publish to Azure
```sh
func host start --build
func azure functionapp publish $functionAppName
```

## Continuous Delpoyment

<https://docs.microsoft.com/en-us/azure/azure-functions/functions-continuous-deployment>