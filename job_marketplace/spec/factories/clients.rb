FactoryBot.define do
  factory :client do
    name { "Test Client" }
    company { "Test Company" }
    sequence(:email) { |n| "client#{n}@example.com" }
  end
end