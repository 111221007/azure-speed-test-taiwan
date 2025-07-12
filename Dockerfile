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
RUN npm ci --omit=dev
COPY ui/ .
RUN npm run build

# Use a .NET runtime image to serve the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install nginx and clean up
RUN apt-get update && apt-get install -y nginx curl && rm -rf /var/lib/apt/lists/*

# Copy custom nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf
RUN rm -rf /usr/share/nginx/html/*

# Copy frontend dist folder to nginx html directory
COPY --from=build-frontend /app/dist/azure-speed-test/browser /usr/share/nginx/html

# Copy backend from the build stage
COPY --from=build-backend /app/publish /app

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV NODE_ENV=production

# Expose port (Heroku will provide PORT env var)
EXPOSE $PORT

# Create a startup script
RUN echo '#!/bin/bash\n\
# Update nginx to listen on the PORT provided by Heroku\n\
if [ ! -z "$PORT" ]; then\n\
    sed -i "s/80/$PORT/g" /etc/nginx/nginx.conf\n\
fi\n\
\n\
# Start nginx in background\n\
nginx -g "daemon off;" &\n\
\n\
# Start the .NET application\n\
dotnet /app/AzureSpeed.dll --urls http://*:$PORT' > /start.sh

RUN chmod +x /start.sh

# Start the application
CMD ["/start.sh"]
