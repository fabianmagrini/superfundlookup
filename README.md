# SuperFund Lookup

POC using Azure

## Prerequisites

.Net Core 2.2 (WIP converting to net5.0)

## Setup Azure Environment

For instructions on setting up the Azure Environment see [SuperFundEnvironment/](here)

## Azure Blob Storage

The POC uses files stored in Azure Blob Storage in some cases. The references below will be helpful when uploading files.

References:

<https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli>
<https://docs.microsoft.com/en-us/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show>

Download data from:
<https://superfundlookup.gov.au/Tools/DownloadUsiList>

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

How to deploy chnage to AKS

### settings

```sh
containerRegistryName=...
az acr login --name $containerRegistryName
az acr repository list --name $containerRegistryName --output table
```

### build docker container

```sh
ACR_LOGIN_SERVER=...
docker build -t superfundapi . -f SuperFundAPI/Dockerfile
docker tag superfundapi $ACR_LOGIN_SERVER/superfundapi:latest
docker push $ACR_LOGIN_SERVER/superfundapi:latest
```

### set keyvault values

```sh
keyVaultName=...
az keyvault secret set --vault-name $keyVaultName --name "SuperFundApiStorageKey" --value "..."
```

### Run deployment

```sh
cd SuperFundAKS
chmod 775 deploy.sh
export subscriptionid="..."
export tenantid="..."
source ./deploy.sh aks-superfundapi.yaml.template
```

### Scale deployment

```sh
kubectl scale deployment supefundapi --replicas=1
```
