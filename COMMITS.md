# Commits

## TASK-01 Initial commit

Initializes the project with the technical challenge as the README.md file and
COMMITS.md describing the commits.

## TASK-02 Add initial rate limiter implementation

Adds the rate limiter implementation with specs.

## TASK-03 Job Marketplace API Implementation with TLS

Implements a Rails Job Marketplace API with the following features:
- PostgreSQL database with models for Client, Opportunity, JobSeeker, and JobApplication
- RESTful API endpoints with proper validations and associations
- Docker containerization with PostgreSQL and Redis services
- Background job processing with Sidekiq for notifications
- Redis caching for search optimization
- Pagination and search functionality
- SSL/TLS support for local development
- Swagger API documentation accessible via HTTPS

## TASK-04 Solution Finalization

- Updates main README with comprehensive project overview and instructions
- Sets proper proprietary license on all components
- Ensures consistent documentation across all parts of the application
- Verifies all functionality is working correctly
- Prepares repository for submission

## TASK-05 DevOps Continuous Deployment

- Configures GitHub Actions CI workflow for automated testing
- Sets up separate test jobs for rate limiter and job marketplace components
- Configures test environments with PostgreSQL and Redis services
- Ensures SSL certificates are properly generated for testing
- Validates that all tests pass in the CI environment

## TASK-06 Finalize Submission

- Fixes health endpoint by removing non-existent version attribute
- Implements API testing script for complete endpoint verification
- Updates authentication to allow development mode testing without JWT tokens
- Enhances error handling and response formatting in test script
- Adds detailed documentation for running tests and verifying functionality
- Confirms 100% test coverage for rate limiter component
- Validates all API endpoints with proper request/response formatting
