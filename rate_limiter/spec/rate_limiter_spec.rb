require 'rspec'
require_relative 'spec_helper'
require_relative '../lib/rate_limiter'

RSpec.describe RateLimiter do
  describe '#initialize' do
    it 'raises error with non-positive time window' do
      expect { RateLimiter.new(0, 3) }.to raise_error(ArgumentError)
      expect { RateLimiter.new(-1, 3) }.to raise_error(ArgumentError)
    end

    it 'raises error with non-positive max requests' do
      expect { RateLimiter.new(30, 0) }.to raise_error(ArgumentError)
      expect { RateLimiter.new(30, -1) }.to raise_error(ArgumentError)
    end

    it 'creates instance with valid parameters' do
      expect { RateLimiter.new(30, 3) }.not_to raise_error
    end
  end

  describe '#allow_request?' do
    let(:rate_limiter) { RateLimiter.new(30, 3) }

    it 'raises error with nil timestamp' do
      expect { rate_limiter.allow_request?(nil, 1) }.to raise_error(ArgumentError)
    end

    it 'raises error with nil user_id' do
      expect { rate_limiter.allow_request?(1700000000, nil) }.to raise_error(ArgumentError)
    end

    it 'raises error when timestamp goes backwards significantly' do
      rate_limiter.allow_request?(1700000010, 1)
      expect { rate_limiter.allow_request?(1700000008, 1) }.to raise_error(RateLimiter::InvalidTimestampError)
    end

    it 'allows small clock skew' do
      rate_limiter.allow_request?(1700000010, 1)
      expect { rate_limiter.allow_request?(1700000009, 1) }.not_to raise_error
    end

    context 'with sliding window' do
      it 'allows requests within the rate limit' do
        expect(rate_limiter.allow_request?(1700000000, 1)).to be true # 1st request
        expect(rate_limiter.allow_request?(1700000010, 1)).to be true # 2nd request
        expect(rate_limiter.allow_request?(1700000020, 1)).to be true # 3rd request
      end

      it 'blocks requests that exceed the rate limit' do
        expect(rate_limiter.allow_request?(1700000000, 1)).to be true # 1st request
        expect(rate_limiter.allow_request?(1700000010, 1)).to be true # 2nd request
        expect(rate_limiter.allow_request?(1700000020, 1)).to be true # 3rd request
        expect(rate_limiter.allow_request?(1700000025, 1)).to be false # 4th request (blocked)
      end

      it 'allows requests after window expiration' do
        expect(rate_limiter.allow_request?(1700000000, 1)).to be true # 1st request
        expect(rate_limiter.allow_request?(1700000010, 1)).to be true # 2nd request
        expect(rate_limiter.allow_request?(1700000020, 1)).to be true # 3rd request
        expect(rate_limiter.allow_request?(1700000025, 1)).to be false # 4th request (blocked)

        # After 30 seconds from first request, another request should be allowed
        expect(rate_limiter.allow_request?(1700000031, 1)).to be true # Request allowed again
      end

      it 'handles multiple users independently' do
        # User 1
        expect(rate_limiter.allow_request?(1700000000, 1)).to be true # 1st request
        expect(rate_limiter.allow_request?(1700000010, 1)).to be true # 2nd request
        expect(rate_limiter.allow_request?(1700000020, 1)).to be true # 3rd request
        expect(rate_limiter.allow_request?(1700000025, 1)).to be false # 4th request (blocked)

        # User 2 (should be unaffected by User 1's rate limit)
        expect(rate_limiter.allow_request?(1700000000, 2)).to be true # 1st request
        expect(rate_limiter.allow_request?(1700000010, 2)).to be true # 2nd request
        expect(rate_limiter.allow_request?(1700000020, 2)).to be true # 3rd request
        expect(rate_limiter.allow_request?(1700000025, 2)).to be false # 4th request (blocked)
      end
    end
  end

  describe 'performance and scalability' do
    it 'handles high volume of requests efficiently' do
      rate_limiter = RateLimiter.new(30, 1000)
      user_count = 1000
      requests_per_user = 100

      start_time = Time.now

      user_count.times do |user_id|
        requests_per_user.times do |i|
          timestamp = 1700000000 + i
          rate_limiter.allow_request?(timestamp, user_id)
        end
      end

      duration = Time.now - start_time
      puts "\nProcessed #{user_count * requests_per_user} requests in #{duration} seconds\n"

      # A rough performance benchmark
      expect(duration).to be < 10 # Should process 100,000 requests in under 10 seconds
    end
  end

  describe 'sliding window behavior' do
    it 'correctly implements sliding window approach' do
      rate_limiter = RateLimiter.new(30, 3)

      # Fill up the window
      expect(rate_limiter.allow_request?(1700000000, 1)).to be true # t=0
      expect(rate_limiter.allow_request?(1700000010, 1)).to be true # t=10
      expect(rate_limiter.allow_request?(1700000020, 1)).to be true # t=20
      expect(rate_limiter.allow_request?(1700000025, 1)).to be false # t=25 (blocked)

      # After the first request expires (t=0 + 30 = t=30)
      expect(rate_limiter.allow_request?(1700000031, 1)).to be true # t=31 (allowed)

      # Now we should have requests at t=10, t=20, t=31
      expect(rate_limiter.allow_request?(1700000035, 1)).to be false # t=35 (blocked)

      # After the second request expires (t=10 + 30 = t=40)
      expect(rate_limiter.allow_request?(1700000041, 1)).to be true # t=41 (allowed)

      # Now we should have requests at t=20, t=31, t=41
      expect(rate_limiter.allow_request?(1700000045, 1)).to be false # t=45 (blocked)

      # After the third request expires (t=20 + 30 = t=50)
      expect(rate_limiter.allow_request?(1700000051, 1)).to be true # t=51 (allowed)
    end
  end

  describe 'cleanup of inactive users' do
    let(:rate_limiter) { RateLimiter.new(30, 1000) }

    it 'cleans up inactive users after threshold' do
      # Make some requests for two users
      expect(rate_limiter.allow_request?(1700000000, 1)).to be true
      expect(rate_limiter.allow_request?(1700000000, 2)).to be true

      # Trigger cleanup by making 1000 requests for a third user
      1000.times do |i|
        rate_limiter.allow_request?(1700003600 + i, 3) # 1 hour later
      end

      # User 1 and 2 should have been cleaned up
      # We can verify this by checking their request counts
      expect(rate_limiter.current_request_count(1)).to eq(0)
      expect(rate_limiter.current_request_count(2)).to eq(0)
      expect(rate_limiter.current_request_count(3)).to be > 0
    end

    it 'keeps active users data' do
      # Make requests for two users
      expect(rate_limiter.allow_request?(1700000000, 1)).to be true
      expect(rate_limiter.allow_request?(1700000000, 2)).to be true

      # Keep user 1 active, let user 2 become inactive
      990.times do |i|
        rate_limiter.allow_request?(1700000000 + i, 1)
      end

      # Trigger cleanup with final requests for user 1
      10.times do |i|
        rate_limiter.allow_request?(1700003600 + i, 1) # 1 hour later
      end

      # User 2 should be cleaned up, but user 1 should remain
      expect(rate_limiter.current_request_count(2)).to eq(0)
      expect(rate_limiter.current_request_count(1)).to be > 0
    end
  end
end

RSpec.configure do |config|
  config.after(:suite) do
    coverage_result = SimpleCov.result
    puts "\nCoverage Report:"
    puts "Total Coverage: #{coverage_result.covered_percent.round(2)}%"
    puts "Total Lines: #{coverage_result.total_lines}"
    puts "Covered Lines: #{coverage_result.covered_lines}"
  end
end
