# SuperFund Lookup

POC using Azure

## Prerequisites

.Net Core 2.2

## SuperFund CLI

### Running CLI

```sh
cd SuperFundCLI
dotnet run
```

### Running the CLI tests

```sh
dotnet test SuperFundCLI.Tests/SuperFundCLI.Tests.csproj
```

## SuperFund API

### setting secrets for dev
```sh
dotnet user-secrets set "SuperFundApi:StorageAccount" "..."
dotnet user-secrets set "SuperFundApi:StorageKey" "..."
dotnet user-secrets set "SuperFundApi:TableName" "..."
```

### run api
```sh
cd SuperFundAPI
dotnet run
```

### create container registry
```sh
az acr create --resource-group SuperfundLookupRG --name SuperFundContainerRegistry --sku Basic
az acr login --name SuperFundContainerRegistry
az acr repository list --name superfundcontainerregistry --output table
```

### build docker container
```sh
docker build -t superfundapi .
docker tag superfundapi superfundcontainerregistry.azurecr.io/superfundapi:v1
docker push superfundcontainerregistry.azurecr.io/superfundapi:v1
```

### create keyvault
```sh
az keyvault create --name "SuperFundKV" --resource-group "SuperfundLookupRG" --location australiaeast
az keyvault secret set --vault-name "SuperFundKV" --name "SuperFundApi--StorageAccount" --value "..."
az keyvault secret set --vault-name "SuperFundKV" --name "SuperFundApi--StorageKey" --value "..."
az keyvault secret set --vault-name "SuperFundKV" --name "SuperFundApi--TableName" --value "..."
```

### Create service principal, store its password in AKV (the registry *password*)
```sh
az keyvault secret set \
  --vault-name SuperFundKV \
  --name superfundcontainerregistry-pull-pwd \
  --value $(az ad sp create-for-rbac \
                --name http://superfundcontainerregistry-pull \
                --scopes $(az acr show --name superfundcontainerregistry --query id --output tsv) \
                --role acrpull \
                --query password \
                --output tsv)
```

### Store service principal ID in AKV (the registry *username*)
```sh
az keyvault secret set \
    --vault-name SuperFundKV \
    --name superfundcontainerregistry-pull-usr \
    --value $(az ad sp show --id http://superfundcontainerregistry-pull --query appId --output tsv)
ACR_LOGIN_SERVER=$(az acr show --name superfundcontainerregistry --resource-group SuperfundLookupRG --query "loginServer" --output tsv)
```

### create container
```sh
az container create \
    --name superfundapicontainer \
    --resource-group SuperfundLookupRG \
    --image $ACR_LOGIN_SERVER/superfundapi:v1 \
    --registry-login-server $ACR_LOGIN_SERVER \
    --registry-username $(az keyvault secret show --vault-name SuperFundKV -n superfundcontainerregistry-pull-usr --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name SuperFundKV -n superfundcontainerregistry-pull-pwd --query value -o tsv) \
    --dns-name-label {...}-$RANDOM \
    --query ipAddress.fqdn
```

### show container
```sh
az container show --resource-group SuperfundLookupRG --name superfundapicontainer --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table
```
### container logs
```sh
az container logs --resource-group SuperfundLookupRG --name superfundapicontainer
```
### attach container
```sh
az container attach --resource-group SuperfundLookupRG --name superfundapicontainer
```
### set policy for container for accessing keyvault
```sh
az keyvault set-policy --name SuperFundKV --object-id {...} --secret-permissions get list
```