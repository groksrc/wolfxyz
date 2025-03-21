class Opportunity < ApplicationRecord
  belongs_to :client
  has_many :job_applications
  
  validates :title, :description, :salary, presence: true
  validates :salary, numericality: { greater_than: 0 }
  
  scope :with_client, -> { includes(:client) }
end
