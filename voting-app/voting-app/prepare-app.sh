#!/bin/bash

echo "=== Preparing Docker Voting Application ==="

# Create Docker network
echo "Creating Docker network..."
docker network create voting-network 2>/dev/null || echo "Network already exists"

# Create named volumes for persistent storage
echo "Creating persistent volumes..."
docker volume create postgres-data 2>/dev/null || echo "Volume postgres-data already exists"
docker volume create redis-data 2>/dev/null || echo "Volume redis-data already exists"

# Build custom images
echo "Building vote service image..."
cd vote
docker build -t voting-app/vote:latest .
cd ..

echo "Building result service image..."
cd result
docker build -t voting-app/result:latest .
cd ..

echo "Building worker service image..."
cd worker
docker build -t voting-app/worker:latest .
cd ..

echo "=== Preparation completed successfully! ==="
echo "Next step: Run ./start-app.sh to start the application"
