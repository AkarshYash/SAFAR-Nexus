#!/bin/bash

# Local Testing Setup Script
# Starts all services using Docker Compose

set -e

echo "=========================================="
echo "SAFAR-Nexus Local Testing Environment"
echo "=========================================="

# Check Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker not found. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose not found. Please install Docker Compose."
    exit 1
fi

# Create credentials directory if not exists
mkdir -p credentials

# Check if service account key exists
if [ ! -f credentials/service-account-dev.json ]; then
    echo "Warning: GCS service account key not found at credentials/service-account-dev.json"
    echo "Creating dummy file (GCS features won't work)"
    echo '{}' > credentials/service-account-dev.json
fi

# Create scripts directory if not exists
mkdir -p scripts

# Start services
echo ""
echo "Starting services with Docker Compose..."
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to be ready..."
sleep 5

# Check database
echo "Checking database..."
docker-compose exec -T database pg_isready -U safar_user -d safar_nexus || echo "Database not ready yet"

# Check backend
echo "Checking backend..."
sleep 10
curl -f http://localhost:8000/health || echo "Backend not ready yet"

echo ""
echo "=========================================="
echo "Services Started!"
echo "=========================================="
echo "Backend API: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo "Database: localhost:5432"
echo "  Database: safar_nexus"
echo "  User: safar_user"
echo "  Password: safar_password_change_in_production"
echo ""
echo "View logs:"
echo "  docker-compose logs -f backend"
echo "  docker-compose logs -f database"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
echo "Test registration:"
echo '  curl -X POST http://localhost:8000/api/v1/auth/register \'
echo '    -H "Content-Type: application/json" \'
echo '    -d '"'"'{"email":"test@test.com","password":"test1234","name":"Test User"}'"'"
echo "=========================================="
