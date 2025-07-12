# Multi-stage build for production deployment on Heroku

# Build .NET Backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-backend
WORKDIR /src
COPY ["api/AzureSpeed/AzureSpeed.csproj", "backend/"]
RUN dotnet restore "backend/AzureSpeed.csproj"
COPY api/AzureSpeed/ backend/
WORKDIR "/src/backend"
RUN dotnet publish "AzureSpeed.csproj" -c Release -o /app/publish

# Build Angular Frontend
FROM node:20-alpine AS build-frontend
WORKDIR /app
COPY ["ui/package.json", "ui/package-lock.json*", "./"]
RUN npm ci
COPY ui/ .
RUN npm run build:prod

# Final production image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy published backend
COPY --from=build-backend /app/publish /app

# Copy built frontend to wwwroot
COPY --from=build-frontend /app/dist/azure-speed-test/browser /app/wwwroot

# Set production environment
ENV ASPNETCORE_ENVIRONMENT=Production
ENV NODE_ENV=production

# Heroku dynamically assigns port
EXPOSE $PORT

# Start the application
CMD ["dotnet", "AzureSpeed.dll"]
