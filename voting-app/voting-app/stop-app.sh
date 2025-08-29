#!/bin/bash

echo "=== Stopping Docker Voting Application ==="

# Stop all containers
containers=("vote" "result" "worker" "redis" "postgres")

for container in "${containers[@]}"; do
    if docker ps -q --filter "name=$container" | grep -q .; then
        echo "Stopping $container..."
        docker stop "$container"
    else
        echo "$container is not running"
    fi
done

echo "=== Application stopped successfully! ==="
echo "Data is preserved in persistent volumes."
echo "Run ./start-app.sh to restart the application."
