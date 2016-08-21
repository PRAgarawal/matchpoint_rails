class Court < ApplicationRecord
  has_one :postal_address, as: :postal_addressable
  has_many :court_users
  has_many :users, through: :court_users
  has_many :matches

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
end
