# syntax=docker/dockerfile:1

# --------------------------------------------------------------
# Stage 1: build
# --------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia csproj primeiro pra aproveitar cache do Docker em restores.
# Se nenhum .csproj mudou, o restore é cacheado.
COPY backend/api/OctoSense.slnx ./backend/api/
COPY backend/api/src/OctoSense.Domain/OctoSense.Domain.csproj ./backend/api/src/OctoSense.Domain/
COPY backend/api/src/OctoSense.Application/OctoSense.Application.csproj ./backend/api/src/OctoSense.Application/
COPY backend/api/src/OctoSense.Infrastructure/OctoSense.Infrastructure.csproj ./backend/api/src/OctoSense.Infrastructure/
COPY backend/api/src/OctoSense.Api/OctoSense.Api.csproj ./backend/api/src/OctoSense.Api/

RUN dotnet restore backend/api/src/OctoSense.Api/OctoSense.Api.csproj

# Copia o resto do código
COPY backend/api/ ./backend/api/

# Publica em Release
RUN dotnet publish backend/api/src/OctoSense.Api/OctoSense.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish

# --------------------------------------------------------------
# Stage 2: runtime
# --------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app

# Escuta na 8080 dentro do container (Kestrel lê ASPNETCORE_URLS).
# O docker-compose mapeia pra 5137 no host.
EXPOSE 8080

# A imagem oficial do .NET 8+ já inclui usuário não-root "app".
# Rodar como não-root reduz superfície de ataque se houver RCE.
USER app

COPY --from=build /app/publish ./

ENTRYPOINT ["dotnet", "OctoSense.Api.dll"]
