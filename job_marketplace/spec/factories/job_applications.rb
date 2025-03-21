FactoryBot.define do
  factory :job_application do
    association :job_seeker
    association :opportunity
    status { "pending" }
  end
end