class Court < ApplicationRecord
  has_one :postal_address, as: :postal_addressable
  accepts_nested_attributes_for :postal_address
  has_many :court_users
  has_many :users, through: :court_users
  has_many :matches
  belongs_to :requester, class_name: 'User', foreign_key: 'requested_by_id'

  after_create :notify_admin

  scope :not_joined, -> {
    where(is_confirmed: true)
        .where('id NOT IN (SELECT court_id from court_users WHERE user_id = ?)',
               User.current_user.id)
  }

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  # Let Sri know when a court is created
  def notify_admin

  end
end
