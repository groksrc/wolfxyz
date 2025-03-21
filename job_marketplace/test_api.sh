#!/bin/bash

# Set the script to exit immediately if a command fails
set -e

echo "Ensuring Docker containers are running..."
cd /Users/drew/code/wolfxyz/job_marketplace

# Check if containers are running
if ! docker-compose ps | grep -q "web.*Up"; then
  echo "Starting Docker containers..."
  docker-compose up -d
  
  # Wait for services to be ready
  echo "Waiting for services to be ready..."
  sleep 10
  
  # Setup database if needed
  echo "Setting up database..."
  docker-compose exec -T web bin/rails db:setup || true
else
  echo "Docker containers are already running."
fi

# API base URL - using HTTPS
BASE_URL="https://localhost:3000/api/v1"

# Function to make API requests with pretty-printing of JSON and timeout
# Skip SSL verification with -k flag
function api_request() {
  method=$1
  endpoint=$2
  data=$3
  description=$4
  
  echo "=== $description ==="
  echo "$method $endpoint"
  
  # For test environment, we can skip authentication as it's disabled in Rails.env.test?
  # But we're running in development environment, so modify the app to allow skipping in development too
  if [ -z "$data" ]; then
    output=$(docker-compose exec -T web curl -s -k -m 5 -X $method "$BASE_URL$endpoint" || echo "Request timed out or failed")
  else
    output=$(docker-compose exec -T web curl -s -k -m 5 -X $method "$BASE_URL$endpoint" -H "Content-Type: application/json" -d "$data" || echo "Request timed out or failed")
  fi
  
  # Format JSON output if the response is valid JSON
  echo "$output" | python -m json.tool 2>/dev/null || echo "$output"
  
  echo ""
}

# First verify services health
echo "===== SYSTEM HEALTH CHECK ====="
echo "Testing health endpoint"
docker-compose exec -T web curl -s -k https://localhost:3000/health | python -m json.tool
echo ""

# Access Swagger documentation
echo "===== SWAGGER DOCUMENTATION ====="
echo "Checking Swagger API documentation"
swagger_response=$(docker-compose exec -T web curl -s -k -o /dev/null -w "%{http_code}" https://localhost:3000/api-docs/v1/swagger.yaml)
if [ "$swagger_response" -eq 200 ]; then
  echo "Swagger documentation is accessible (HTTP 200)"
else
  echo "Warning: Swagger documentation returned HTTP $swagger_response"
fi
echo ""

echo "===== STARTING API TESTS ====="

# Opportunity CRUD operations
api_request "GET" "/opportunities" "" "List all opportunities"
api_request "GET" "/opportunities?page=1&per_page=2" "" "Get opportunities with pagination"
api_request "GET" "/opportunities?search=Developer" "" "Search opportunities by keyword"

# Create new opportunity
api_request "POST" "/opportunities" '{
  "opportunity": {
    "title": "Full Stack Developer",
    "description": "Join our team to build amazing web applications.",
    "salary": 95000,
    "client_id": 1
  }
}' "Create a new opportunity"

# Note: The API doesn't have a show endpoint for individual opportunities
# So we'll skip testing that

# Apply for an opportunity
api_request "POST" "/opportunities/1/apply" '{
  "job_seeker_id": 1
}' "Apply for an opportunity"

echo "All tests completed!"