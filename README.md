# Wolf - Ruby on Rails Staff Engineer Technical Assessment

This repository contains my solutions to the two-part Ruby on Rails Staff Engineer Technical Assessment.

## Overview

The assessment consists of two main parts:

1. **Rate Limiter Implementation** - An algorithmic challenge to implement an efficient rate limiter in Ruby.
2. **Job Marketplace API** - A Rails application implementing a job marketplace with various performance optimizations.

## Part 1: Rate Limiter

The rate limiter implements a sliding window approach to efficiently throttle API requests. Key features include:

- O(1) time complexity for request validation
- Thread-safe implementation for concurrent access
- Memory-efficient storage using optimized data structures
- Automatic cleanup of inactive users

### Directory Structure

All code for the rate limiter is contained in the `rate_limiter` directory.

### Running Tests

```bash
cd rate_limiter
bundle install
bundle exec rspec
```

## Part 2: Job Marketplace API

The Job Marketplace API is a Ruby on Rails application that provides the following features:

- RESTful API endpoints for managing job opportunities
- PostgreSQL database with optimized queries and proper indexing
- Redis caching for improved search performance
- Background job processing with Sidekiq
- Swagger API documentation
- Docker containerization
- TLS/HTTPS support for local development

### Directory Structure

All code for the job marketplace API is contained in the `job_marketplace` directory.

### Running the Application

```bash
cd job_marketplace
docker-compose up -d
```

The API will be available at https://localhost:3000 and the Swagger documentation at https://localhost:3000/api-docs.

## Implementation Decisions

### Rate Limiter

- Used a circular buffer approach for O(1) time complexity
- Implemented thread safety with mutex locks
- Added automatic cleanup to prevent memory leaks
- Provided comprehensive test coverage

### Job Marketplace API

- Implemented eager loading to fix N+1 query issues
- Used Redis for caching frequent searches
- Added proper database indexes for performance
- Implemented background processing for notifications
- Added Docker containerization for easy setup
- Configured TLS for secure local development

## Testing

Both parts of the assessment include comprehensive test suites with high coverage. The tests demonstrate the correctness and performance of the implementations.

## License

All rights reserved. This code is proprietary and confidential. Unauthorized copying, distribution, modification, public display, or public performance of this proprietary work is strictly prohibited.