# SuperFund AKS

Azure Kubernetes Service

References:

* <https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough>
* <https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal>
* <https://docs.microsoft.com/en-us/azure/dev-spaces/quickstart-netcore>
* <https://docs.microsoft.com/en-us/azure/aks/update-credentials>
* <https://azure.microsoft.com/en-gb/topic/what-is-kubernetes>
* <https://azure.microsoft.com/en-gb/services/kubernetes-service>
* <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app>

* <https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster>
* <https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/design-develop-containerized-apps/build-aspnet-core-applications-linux-containers-aks-kubernetes>

* <https://docs.microsoft.com/en-us/azure/aks/faq>
* <https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security>
* <https://github.com/Azure/aad-pod-identity>
* <https://github.com/Azure/kubernetes-keyvault-flexvol>
* <https://docs.microsoft.com/en-us/azure/aks/use-network-policies>

## Run deployment

```sh
chmod 775 setup.sh
./setup.sh
```

## Connect to the cluster

### Install kubectl locally

```sh
az aks install-cli
```

To configure kubectl to connect to your Kubernetes cluster, use the az aks get-credentials command. This command downloads credentials and configures the Kubernetes CLI to use them.

```sh
resourceGroupName=<resource group name>
clusterName=<AKS cluster name>
az aks get-credentials --resource-group $resourceGroupName --name $clusterName
```

To verify the connection to your cluster, use the kubectl get command to return a list of the cluster nodes.

```sh
kubectl get nodes
```

## Run the application

The yaml for the application was inspired from here <https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/design-develop-containerized-apps/build-aspnet-core-applications-linux-containers-aks-kubernetes>.

Uses flexvol for integration to KeyVault <https://github.com/Azure/kubernetes-keyvault-flexvol>.

Created a simple deploy script to substitute some variables into a template yaml for the deployment.

```sh
chmod 775 deploy.sh
export subscriptionid="..."
export tenantid="..."
source ./deploy.sh aks-superfundapi.yaml.template
```

### Test the application

When the application runs, a Kubernetes service exposes the application front end to the internet. This process can take a few minutes to complete.

To monitor progress, use the kubectl get service command with the --watch argument.

```sh
kubectl get service supefundapi-kub-app --watch
```

### List pods

```sh
kubectl get pods
```

## Start the Kubernetes dashboard

```sh
resourceGroupName=<resource group name>
clusterName=<AKS cluster name>
az aks browse --resource-group $resourceGroupName --name $clusterName
```

## Clean up deployment

```sh
resourceGroupName=<resource group name>
clusterName=<AKS cluster name>
az group delete --name $resourceGroupName --yes --no-wait
```

When you delete the cluster, the Azure Active Directory service principal used by the AKS cluster is not removed. For steps on how to remove the service principal, see AKS service principal considerations and deletion.

<https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal#additional-considerations>

```sh
az ad sp delete --id $(az aks show -g $resourceGroupName -n $clusterName --query servicePrincipalProfile.clientId -o tsv)
rm ~/.azure/aksServicePrincipal.json
```
