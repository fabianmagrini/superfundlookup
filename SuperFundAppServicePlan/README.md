# SuperFund App Service Plan

Deploy a container using an Azure App Service Plan webapp

References:

* <https://docs.microsoft.com/en-us/azure/app-service/containers/tutorial-custom-docker-image>

## Run deployment

```sh
cd SuperFundAppServicePlan
chmod 775 setup.sh
./setup.sh
```

## Test the web app

Verify that the web app works by browsing to it (http://<app-name>.azurewebsites.net).

## Change web app and redeploy

* rebuild and push the new Docker image
* restart the web app for the changes to take effect.

## Access diagnostic logs

turn on container logging

```sh
resourceGroupName=<resource group name>
webappName=<webapp name>
az webapp log config --name $webappName --resource-group $resourceGroupName --docker-container-logging filesystem
```

see the log stream

```sh
az webapp log tail --name $webappName --resource-group $resourceGroupName
```

## Clean up deployment

```sh
resourceGroupName=<resource group name>
az group delete --name $resourceGroupName --yes --no-wait
```
