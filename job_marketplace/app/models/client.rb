class Client < ApplicationRecord
  has_many :opportunities
  
  validates :name, :company, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
end
