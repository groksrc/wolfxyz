FactoryBot.define do
  factory :job_seeker do
    name { "Test Job Seeker" }
    sequence(:email) { |n| "seeker#{n}@example.com" }
    skills { "Ruby, Rails, JavaScript" }
  end
end