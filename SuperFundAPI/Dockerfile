FROM mcr.microsoft.com/dotnet/core/runtime:3.0 AS base
WORKDIR /app

# Copy project files and restore
FROM mcr.microsoft.com/dotnet/core/sdk:3.0 AS build
WORKDIR /src
COPY SuperFundAPI/*.csproj  SuperFundAPI/
COPY SuperFundTableStorage/*.csproj SuperFundTableStorage/
RUN dotnet restore SuperFundAPI/SuperFundAPI.csproj
RUN dotnet restore SuperFundTableStorage/SuperFundTableStorage.csproj

# Copy everything and run build
COPY SuperFundAPI/. SuperFundAPI/
COPY SuperFundTableStorage/. SuperFundTableStorage/
WORKDIR /src/SuperFundAPI
RUN dotnet build SuperFundAPI.csproj -c Release -o /app

# Publish runtime artifacts 
FROM build AS publish
RUN dotnet publish SuperFundAPI.csproj -c Release -o /app

# Create final runtime image
FROM base AS final
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "SuperFundAPI.dll"]