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
