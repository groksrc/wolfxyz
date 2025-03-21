class JobApplication < ApplicationRecord
  belongs_to :job_seeker
  belongs_to :opportunity
  
  validates :status, presence: true
  
  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }, default: "pending"
end
