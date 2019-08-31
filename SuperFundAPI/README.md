# SuperFund API

## Prerequisites

.Net Core 2.2

## setting secrets for dev

```sh
dotnet user-secrets set "SuperFundApi:StorageAccount" "..."
dotnet user-secrets set "SuperFundApi:StorageKey" "..."
dotnet user-secrets set "SuperFundApi:TableName" "..."
```

## run api

```sh
cd SuperFundAPI
dotnet run
```

## build docker container

```sh
cd ..
docker build -t superfundapi . -f SuperFundAPI/Dockerfile
```
