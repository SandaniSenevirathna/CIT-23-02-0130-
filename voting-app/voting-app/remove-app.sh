#!/bin/bash

echo "=== Removing Docker Voting Application ==="

# Stop and remove containers
echo "Stopping and removing containers..."
containers=("vote" "result" "worker" "redis" "postgres")

for container in "${containers[@]}"; do
    docker stop "$container" 2>/dev/null || true
    docker rm "$container" 2>/dev/null || true
done

# Remove custom images
echo "Removing custom images..."
docker rmi voting-app/vote:latest 2>/dev/null || true
docker rmi voting-app/result:latest 2>/dev/null || true  
docker rmi voting-app/worker:latest 2>/dev/null || true

# Remove volumes (THIS WILL DELETE ALL DATA!)
echo "Removing persistent volumes..."
docker volume rm postgres-data 2>/dev/null || true
docker volume rm redis-data 2>/dev/null || true

# Remove network
echo "Removing network..."
docker network rm voting-network 2>/dev/null || true

echo "=== All resources removed successfully! ==="
echo "⚠️  All data has been permanently deleted."
