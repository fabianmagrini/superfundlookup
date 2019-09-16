FROM mcr.microsoft.com/dotnet/core/runtime:2.2-stretch-slim AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:2.2-stretch AS build
WORKDIR /src
COPY ["SuperFundCLI.csproj", "./"]
RUN dotnet restore "SuperFundCLI.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "SuperFundCLI.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "SuperFundCLI.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .
ENTRYPOINT ["dotnet", "SuperFundCLI.dll"]