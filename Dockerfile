# Use the official Microsoft ASP.NET Core image to build the backend
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-backend
WORKDIR /src
COPY ["api/AzureSpeed/AzureSpeed.csproj", "backend/"]
RUN dotnet restore "backend/AzureSpeed.csproj"
COPY api/AzureSpeed/ backend/
WORKDIR "/src/backend"
RUN dotnet publish "AzureSpeed.csproj" -c Release -o /app/publish

# Use the official node image to build the Angular app
FROM node:20-alpine AS build-frontend
WORKDIR /app
COPY ["ui/package.json", "ui/package-lock.json*", "./"]
RUN npm ci
COPY ui/ .
RUN npm run build:prod

# Use a .NET runtime image to serve the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy backend from the build stage
COPY --from=build-backend /app/publish /app

# Copy frontend dist folder to the app's wwwroot
COPY --from=build-frontend /app/dist/azure-speed-test/browser /app/wwwroot

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV NODE_ENV=production

# Expose port (Heroku will provide PORT env var)
EXPOSE $PORT

# Start the .NET application (it will serve both API and static files)
CMD ["dotnet", "AzureSpeed.dll"]
