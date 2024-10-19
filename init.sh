#!/bin/bash

# Stop any running container on port 80
echo "Stopping any running containers on port 80..."
docker ps --filter "publish=80" --format "{{.ID}}" | xargs -r docker stop

# Create Docker network if it doesn't already exist
NETWORK_NAME="laravel-network"
if ! docker network ls | grep -q "$NETWORK_NAME"; then
    echo "Creating Docker network: $NETWORK_NAME"
    docker network create $NETWORK_NAME
else
    echo "Docker network $NETWORK_NAME already exists."
fi

# Set MySQL root password and database name
MYSQL_ROOT_PASSWORD="rootpassword123"
MYSQL_DATABASE="laravel_db"

# Run MySQL container
echo "Running MySQL container..."
docker run -d \
    --name mysql-container \
    --network $NETWORK_NAME \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -e MYSQL_DATABASE=$MYSQL_DATABASE \
    -e MYSQL_USER=laraveluser \
    -e MYSQL_PASSWORD=laravelpassword \
    -p 3306:3306 \
    mysql:5.7

# Wait for MySQL to be ready
echo "Waiting for MySQL to initialize..."
sleep 20

# Run Laravel container
echo "Running Laravel container..."
docker run -d \
    --name laravel-container \
    --network $NETWORK_NAME \
    -p 80:80 \
    -h laravel.practiceaws.click \
    -t laravela:latest

# Display MySQL connection info
echo "MySQL container is running."
echo "Root Password: $MYSQL_ROOT_PASSWORD"
echo "Database: $MYSQL_DATABASE"
echo "MySQL User: laraveluser"
echo "MySQL Password: laravelpassword"
echo "Use the MySQL container as host: mysql-container"

# Check container statuses
echo "Checking status of running containers..."
docker ps

# Check if everything is running correctly
if docker ps | grep -q 'laravel-container' && docker ps | grep -q 'mysql-container'; then
    echo "Both Laravel and MySQL containers are running successfully!"
else
    echo "Error: One or both containers failed to start."
fi
