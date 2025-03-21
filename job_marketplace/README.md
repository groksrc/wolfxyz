# Job Marketplace API

A Ruby on Rails API for a job marketplace platform.

## Description

This API allows clients to post job opportunities and job seekers to apply for them. It includes pagination, search functionality, caching, and background job processing.

## Features

- **API Endpoints**
  - GET /api/v1/opportunities (with pagination & search)
  - POST /api/v1/opportunities (clients can create jobs)
  - POST /api/v1/opportunities/:id/apply (job seekers apply)

- **Performance**
  - Eager loading to fix N+1 queries
  - Redis cache for search results
  - Database indexes for better performance

- **Background Jobs**
  - Sidekiq for processing job applications
  - Sends notifications when a job seeker applies

## Requirements

- Ruby 3.4.2
- Rails 8.0.2
- PostgreSQL
- Redis

## Setup

### With Docker

1. Clone the repository
2. Start the services:
```bash
docker compose up -d
```

3. Setup the database:
```bash
docker compose exec web bin/rails db:setup
```

### Without Docker

1. Clone the repository
2. Install dependencies:
```bash
bundle install
```

3. Setup the database:
```bash
bin/rails db:create db:migrate db:seed
```

4. Start Redis and Sidekiq:
```bash
redis-server
bundle exec sidekiq
```

5. Start the server:
```bash
bin/rails server
```

## Testing

Run the test suite:
```bash
bundle exec rspec
```

## API Documentation

The API documentation is available via Swagger UI at https://localhost:3000/api-docs when the application is running.

### GET /api/v1/opportunities

Returns a paginated list of job opportunities with optional search.

**Query Parameters:**
- `page`: Page number (default: 1)
- `per_page`: Items per page (default: 10)
- `search`: Search term for title and description

**Example Response:**
```json
{
  "opportunities": [
    {
      "id": 1,
      "title": "Senior Rails Developer",
      "description": "We're looking for a senior Rails developer...",
      "salary": "120000.0",
      "client": {
        "id": 1,
        "name": "TechCorp Inc.",
        "company": "TechCorp"
      }
    }
  ],
  "pagination": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 25
  }
}
```

### POST /api/v1/opportunities

Creates a new job opportunity.

**Request Body:**
```json
{
  "opportunity": {
    "title": "Full Stack Developer",
    "description": "Join our team to build amazing web applications",
    "salary": 95000.00,
    "client_id": 1
  }
}
```

### POST /api/v1/opportunities/:id/apply

Allows a job seeker to apply for a job opportunity.

**Request Body:**
```json
{
  "job_seeker_id": 1
}
```

## License

All rights reserved. This code is proprietary and confidential. Unauthorized copying, distribution, modification, public display, or public performance of this proprietary work is strictly prohibited.
