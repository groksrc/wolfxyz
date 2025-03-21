class JobSeeker < ApplicationRecord
  has_many :job_applications
  has_many :opportunities, through: :job_applications
  
  validates :name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
