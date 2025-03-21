FactoryBot.define do
  factory :opportunity do
    title { "Test Opportunity" }
    description { "This is a test opportunity description" }
    salary { 100000.00 }
    association :client
  end
end