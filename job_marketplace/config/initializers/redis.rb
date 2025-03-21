require 'redis'

REDIS_CLIENT = Redis.new(
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  timeout: 1
)

# Configure Rails cache store
Rails.application.config.cache_store = :redis_cache_store, {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  expires_in: 1.hour,
  namespace: 'job_marketplace:cache'
}
