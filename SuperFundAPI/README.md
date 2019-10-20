# SuperFund API

## Prerequisites

* .Net Core 3.0

## setting secrets for dev

```sh
dotnet user-secrets set "SuperFundApiStorageKey" "..."
```

## run api

```sh
cd SuperFundAPI
dotnet run
```

## build docker container

Reference:

* <https://github.com/dotnet/dotnet-docker/tree/master/samples/dotnetapp>

```sh
cd ..
docker build -t superfundapi . -f SuperFundAPI/Dockerfile
```
