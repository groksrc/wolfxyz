# Temporarily disabled until we resolve the configuration issues
# class Rack::Attack
#   ### Configure Cache ###
#   cache = ActiveSupport::Cache::RedisCacheStore.new(
#     url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
#   )
#   Rack::Attack.cache_store = cache
#
#   ### Rate Limiting ###
#   # Limit all API requests to 300 per 5 minutes per IP
#   throttle('api/ip', limit: 300, period: 5.minutes) do |req|
#     req.ip if req.path.start_with?('/api/')
#   end
#
#   # Limit POST requests to job applications to 10 per hour per IP
#   throttle('applications/ip', limit: 10, period: 1.hour) do |req|
#     if req.path =~ %r{/api/v1/opportunities/\d+/apply} && req.post?
#       req.ip
#     end
#   end
#
#   ### Response ###
#   self.throttled_response = lambda do |env|
#     now = Time.now
#     match_data = env['rack.attack.match_data']
#
#     headers = {
#       'Content-Type' => 'application/json',
#       'X-RateLimit-Limit' => match_data[:limit].to_s,
#       'X-RateLimit-Remaining' => '0',
#       'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
#     }
#
#     [429, headers, [{ error: "Rate limit exceeded. Please try again later." }.to_json]]
#   end
# end

class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
  )

  # Skip rate limiting in test environment
  unless Rails.env.test?
    ### Rate Limiting ###
    # Limit all API requests to 300 per 5 minutes per IP
    throttle('api/ip', limit: 300, period: 5.minutes) do |req|
      req.ip if req.path.start_with?('/api/')
    end

    # Limit POST requests to job applications to 10 per hour per IP
    throttle('applications/ip', limit: 10, period: 1.hour) do |req|
      if req.path =~ %r{/api/v1/opportunities/\d+/apply} && req.post?
        req.ip
      end
    end
  end

  ### Response ###
  self.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']

    headers = {
      'Content-Type' => 'application/json',
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [429, headers, [{ error: "Rate limit exceeded. Please try again later." }.to_json]]
  end
end
