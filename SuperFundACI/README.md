# SuperFund ACI

Azure Container Instances

References:

<https://docs.microsoft.com/en-us/azure/container-instances/container-instances-quickstart>
<https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-acr>
<https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aci>
<https://docs.microsoft.com/en-us/azure/container-instances/container-instances-managed-identity>

## Run deployment

```sh
cd SuperFundACI
chmod 775 setup.sh
./setup.sh
```

## build docker container

```sh
cd ..
docker build -t superfundapi . -f SuperFundAPI/Dockerfile
docker tag superfundapi $ACR_LOGIN_SERVER/superfundapi:v1
docker push $ACR_LOGIN_SERVER/superfundapi:v1
```

## set keyvault values

SuperFund API uses Table Storage. Store the secrets in Azure KeyVault that are loaded by the API from configuration.

```sh
keyVaultName=<key vault name>
az keyvault secret set --vault-name $keyVaultName --name "SuperFundApiStorageKey" --value "..."
```

## create azure container instance

```sh
resourceGroupName=<resource group name>
containerInstanceName=<container instance name>
registryUsernameSecretName=<name of secret for registry username>
registryPasswordSecretName=<name of secret for registry password>
az container create \
    --name $containerInstanceName \
    --resource-group $resourceGroupName \
    --image $ACR_LOGIN_SERVER/superfundapi:v1 \
    --registry-login-server $ACR_LOGIN_SERVER \
    --registry-username $(az keyvault secret show --vault-name $keyVaultName -n $registryUsernameSecretName --query value -o tsv) \
    --registry-password $(az keyvault secret show --vault-name $keyVaultName -n $registryPasswordSecretName --query value -o tsv) \
    --dns-name-label $containerInstanceName-$RANDOM \
    --query ipAddress.fqdn \
    --assign-identity
```

## show container

```sh
az container show --resource-group $resourceGroupName --name $containerInstanceName --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" --out table
```

## list containers

```sh
az container list --resource-group $resourceGroupName --output table
```

## container logs

```sh
az container logs --resource-group $resourceGroupName --name $containerInstanceName
```

## attach container

```sh
az container attach --resource-group $resourceGroupName --name $containerInstanceName
```

## set policy for container for accessing keyvault

```sh
spID=$(az container show --resource-group $resourceGroupName --name $containerInstanceName --query identity.principalId --out tsv)
az keyvault set-policy --name $keyVaultName --object-id $spID --secret-permissions get list
```

## Clean up deployment

### remove container only

```sh
resourceGroupName=<resource group name>
containerInstanceName=<container instance name>
az container delete --resource-group $resourceGroupName --name $containerInstanceName
```

### remove resource group

```sh
az group delete --name $resourceGroupName --yes --no-wait
```
