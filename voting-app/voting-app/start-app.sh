#!/bin/bash

echo "=== Starting Docker Voting Application ==="

# Start Redis (vote storage)
echo "Starting Redis service..."
docker run -d \
    --name redis \
    --network voting-network \
    --restart unless-stopped \
    -v redis-data:/data \
    -p 6379:6379 \
    redis:7-alpine redis-server --appendonly yes

# Start PostgreSQL (results database)
echo "Starting PostgreSQL service..."
docker run -d \
    --name postgres \
    --network voting-network \
    --restart unless-stopped \
    -v postgres-data:/var/lib/postgresql/data \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=postgres \
    -e POSTGRES_DB=votes \
    -p 5432:5432 \
    postgres:15-alpine

# Wait for databases to be ready
echo "Waiting for databases to be ready..."
sleep 10

# Start worker service
echo "Starting Worker service..."
docker run -d \
    --name worker \
    --network voting-network \
    --restart unless-stopped \
    voting-app/worker:latest

# Start vote service
echo "Starting Vote service..."
docker run -d \
    --name vote \
    --network voting-network \
    --restart unless-stopped \
    -p 5000:80 \
    voting-app/vote:latest

# Start result service  
echo "Starting Result service..."
docker run -d \
    --name result \
    --network voting-network \
    --restart unless-stopped \
    -p 5001:80 \
    voting-app/result:latest

echo "=== Application started successfully! ==="
echo ""
echo "🗳️  Vote at: http://localhost:5000"
echo "📊 Results at: http://localhost:5001" 
echo ""
echo "Services running:"
docker ps --filter "network=voting-network" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
