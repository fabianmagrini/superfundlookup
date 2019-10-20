# Helm

## Create initial chart

```sh
helm create superfundapi
```

### Linting

```sh
helm lint superfundapi
```

## Rendering the template with configurable values

```sh
helm template --output-dir ./manifests ./superfundapi

helm template \
    --values <values.yaml> \
    --output-dir ./manifests \
    ./superfundapi
```

## Applying the result to the cluster

```sh
kubectl apply --recursive --filename ./manifests/superfundapi
```

## Rendering the template

If you have multiple Azure subscriptions, first query your account with az account list to get a list of subscription ID and tenant ID values:

```sh
az login
az account list --query "[].{name:name, subscriptionId:id, tenantId:tenantId}"
```

Rendering the template:

```sh
chmod 775 deploy.sh
export subscriptionid="..."
export tenantid="..."

helm template --set subscriptionid=$subscriptionid --set tenantid=$tenantid ./superfundapi
```
