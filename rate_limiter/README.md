# Rate Limiter

A Ruby implementation of a rate limiter that uses a sliding window approach.

## Implementation Details

The rate limiter implements a sliding window approach with the following characteristics:
- O(1) time complexity for checking if a request is allowed
- Memory efficient storage of request timestamps
- Thread-safe implementation
- Handles millions of users efficiently

## Implementation Notes

- An array is used to store the request timestamps in a circular buffer. An
alternative approach would be to use a Queue, but considering the requirements
and context, each user's queue will typically have very few elements. Dedicated
queue data structures often have more overhead per element than simple arrays,
especially for very small collections.

- Instead of actually shifting the array (which would be O(n)), we use a front
index pointer and only occasionally compact the array when it becomes beneficial.
This creates an amortized constant time operation.

- The rate limiter is thread-safe. This is important to ensure that the rate
limiter can handle a large number of requests from multiple users concurrently.

- Inactive user cleanup prevents unbounded memory growth.

## Requirements

- Ruby 2.7 or higher should work, but I've only tested it on 3.4.2

## Setup

```bash
bundle install
```

## Testing

The test suite provides 100% coverage of the implementation.
```bash
bundle exec rspec
```

