class Court < ApplicationRecord
  has_one :postal_address, as: :postal_addressable
  accepts_nested_attributes_for :postal_address
  has_many :court_users
  has_many :users, through: :court_users
  has_many :matches
  belongs_to :requester, class_name: 'User', foreign_key: 'requested_by_id'

  after_create :set_court_code
  after_create :join_court
  before_create :mark_as_confirmed

  scope :not_joined, -> {
    where(is_confirmed: true)
        .where('id NOT IN (SELECT court_id from court_users WHERE user_id = ?)',
               User.current_user.id)
  }

  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  # TODO: Remove this (maybe?) once Sri can approve
  def mark_as_confirmed
    self.is_confirmed = true if self.try(:is_confirmed) != nil
  end

  def set_court_code
    # By default, just use the court's name, underscore-ified (e.g. "Hello World" -> "hello_world")
    court_code = self.name.downcase.tr(' ', '_')
    if Court.find_by(court_code: court_code).present?
      court_code = "#{court_code}_#{Court.where(court_code: court_code).count+1}"
    end
    self.update_attributes!(court_code: court_code)
  end

  def join_court
    if User.current_user.present?
      CourtUser.create!(user_id: User.current_user.id, court_id: self.id)
    end
  end
end
