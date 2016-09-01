class Friendship < ApplicationRecord
  attr_accessor :invite_code
  attr_accessor :email

  validates :user_id, presence: true
  validates :friend_id, presence: true
  validate :not_adding_self

  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  def not_adding_self
    errors.add(:friend_id, 'You cannot add yourself as a friend.') if user_id == friend_id
  end
end
