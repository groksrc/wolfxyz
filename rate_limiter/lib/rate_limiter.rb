class RateLimiter
  class InvalidTimestampError < StandardError; end

  # This is just an exercise, but in a real system these should be configurable
  INACTIVE_THRESHOLD = 3600
  CLEANUP_TRIGGER = 1000

  def initialize(time_window, max_requests)
    raise ArgumentError, 'time_window must be positive' if time_window <= 0
    raise ArgumentError, 'max_requests must be positive' if max_requests <= 0

    @time_window = time_window
    @max_requests = max_requests
    # Store timestamps in a circular buffer
    @request_timestamps = Hash.new { |h, k| h[k] = [] }
    # Track index for the next removal - acts as front pointer for the circular queue
    @front_index = Hash.new(0)
    # Track count of requests in window for O(1) check
    @request_counts = Hash.new(0)
    # Track last timestamp for validation
    @last_timestamp = Hash.new(0)
    # Track users for cleanup
    @user_last_seen = {}
    @cleanup_counter = 0
    @mutex = Mutex.new
  end

  def allow_request?(timestamp, user_id)
    raise ArgumentError, 'timestamp cannot be nil' if timestamp.nil?
    raise ArgumentError, 'user_id cannot be nil' if user_id.nil?

    @mutex.synchronize do
      validate_timestamp!(timestamp, user_id)
      cleanup_old_requests(user_id, timestamp)
      @user_last_seen[user_id] = timestamp

      # Check if user has exceeded rate limit
      if @request_counts[user_id] >= @max_requests
        return false
      end

      # Record the new request
      @request_timestamps[user_id].push(timestamp)
      @request_counts[user_id] += 1
      @last_timestamp[user_id] = timestamp

      # Deterministic cleanup trigger
      @cleanup_counter += 1
      if @cleanup_counter >= CLEANUP_TRIGGER
        cleanup_inactive_users(timestamp)
        @cleanup_counter = 0
      end

      true
    end
  end

  # Public method to get current count for testing/monitoring
  def current_request_count(user_id)
    @mutex.synchronize do
      @request_counts[user_id]
    end
  end

  private

  def validate_timestamp!(timestamp, user_id)
    last_ts = @last_timestamp[user_id]
    return if last_ts.zero?

    # Allow some clock skew (1 second) but prevent significant timestamp manipulation
    if timestamp < last_ts - 1
      raise InvalidTimestampError, "Timestamp cannot go backwards more than 1 second"
    end
  end

  def cleanup_old_requests(user_id, current_time)
    cutoff_time = current_time - @time_window
    timestamps = @request_timestamps[user_id]
    front = @front_index[user_id]

    # Skip expired timestamps without shifting the array
    # Just move the front index forward
    while front < timestamps.size && timestamps[front] <= cutoff_time
      front += 1
      @request_counts[user_id] -= 1
    end

    # If we've moved front index significantly, compact the array
    # but only when it's worth the operation (amortized cost)
    if front > 0 && front > timestamps.size / 2
      @request_timestamps[user_id] = timestamps[front..-1] || []
      @front_index[user_id] = 0
    else
      @front_index[user_id] = front
    end

    # Ensure count doesn't go negative due to any edge cases
    @request_counts[user_id] = 0 if @request_counts[user_id] < 0
  end

  def cleanup_inactive_users(current_time)
    @user_last_seen.each do |user_id, last_seen|
      if current_time - last_seen > INACTIVE_THRESHOLD
        @request_timestamps.delete(user_id)
        @request_counts.delete(user_id)
        @last_timestamp.delete(user_id)
        @front_index.delete(user_id)
        @user_last_seen.delete(user_id)
      end
    end
  end
end
