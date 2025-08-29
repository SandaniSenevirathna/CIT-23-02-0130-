# Docker Voting Application

A simple microservices-based voting application built with Docker, demonstrating container orchestration, persistent volumes, and inter-service communication.

## Architecture

### Services
- **Vote Service** (Port 5000): Python Flask web app for casting votes
- **Result Service** (Port 5001): Node.js app displaying real-time results  
- **Worker Service**: Python background service processing votes
- **Redis**: In-memory database for vote queue storage
- **PostgreSQL**: Persistent database for vote results

### Features
- ✅ Multi-container architecture with service isolation
- ✅ Persistent data storage with named volumes
- ✅ Real-time result updates using WebSockets
- ✅ Interactive charts and progress bars
- ✅ Container restart policies for reliability
- ✅ Custom Docker networks for secure communication

## Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose 2.0+ (optional)
- Git
- 8GB+ RAM recommended
- Ports 5000 and 5001 available

### Method 1: Using Shell Scripts

```bash
# Clone repository
git clone <your-repo-url>
cd voting-app

# Make scripts executable
chmod +x *.sh

# 1. Prepare application (build images, create networks/volumes)
./prepare-app.sh

# 2. Start all services
./start-app.sh

# 3. Access the application
# Vote: http://localhost:5000
# Results: http://localhost:5001
