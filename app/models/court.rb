class Court < ApplicationRecord
  has_one :postal_address, as: :postal_addressable
  accepts_nested_attributes_for :postal_address
  has_many :court_users
  has_many :users, through: :court_users
  has_many :matches

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
end
