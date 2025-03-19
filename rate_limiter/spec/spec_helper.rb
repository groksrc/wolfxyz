require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter '/spec/'
  minimum_coverage 100
  formatter SimpleCov::Formatter::SimpleFormatter
end
