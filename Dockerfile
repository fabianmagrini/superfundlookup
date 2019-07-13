FROM microsoft/dotnet:2.2-aspnetcore-runtime AS base
WORKDIR /app

FROM microsoft/dotnet:2.2-sdk AS build
WORKDIR /src
COPY SuperFundAPI/SuperFundAPI.csproj SuperFundAPI/
COPY SuperFundTableStorage/SuperFundTableStorage.csproj SuperFundTableStorage/
RUN dotnet restore SuperFundAPI/SuperFundAPI.csproj
RUN dotnet restore SuperFundTableStorage/SuperFundTableStorage.csproj

COPY SuperFundAPI/. SuperFundAPI/
COPY SuperFundTableStorage/. SuperFundTableStorage/
WORKDIR /src/SuperFundAPI
RUN dotnet build SuperFundAPI.csproj -c Release -o /app

FROM build AS publish
RUN dotnet publish SuperFundAPI.csproj -c Release -o /app

FROM base AS final
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "SuperFundAPI.dll"]

