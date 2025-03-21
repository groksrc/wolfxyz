# CLAUDE.md - Wolfxyz Ruby on Rails Staff Engineer Technical Assessment

## Build & Test Commands
- Setup: `bundle install`
- Run all tests: `bundle exec rspec`
- Run single test: `bundle exec rspec spec/rate_limiter_spec.rb:LINE_NUMBER`
- Test specific example: `bundle exec rspec spec/rate_limiter_spec.rb -e "test description"`
- View coverage: Coverage report generated at coverage/index.html (100% required)

## Code Style Guidelines
- **Naming**: snake_case for variables/methods, CamelCase for classes
- **Error handling**: Define custom error classes that inherit from StandardError
- **Input validation**: Use guard clauses at method beginnings
- **Constants**: Use SCREAMING_SNAKE_CASE for constants
- **Thread safety**: Use Mutex for synchronization in shared resources
- **Privacy**: Use private methods for implementation details
- **Testing**: Write comprehensive RSpec tests with descriptive context blocks
- **Documentation**: Comment complex algorithms and implementation choices
- **Performance**: Prioritize O(1) operations and memory efficiency
- **Error messages**: Provide clear, specific error messages
