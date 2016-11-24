class Friendship < ApplicationRecord
  attr_accessor :invite_code
  attr_accessor :email

  validates :user_id, presence: true
  validates :friend_id, presence: true
  validate :not_adding_self

  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  before_save :notify_friend_requester, if: :is_confirmed_changed?

  def not_adding_self
    errors.add(:friend_id, 'You cannot add yourself as a friend.') if user_id == friend_id
  end

  def self.friendship_for_friend(user_id, friend_id)
    self.where("(user_id = #{user_id} AND friend_id = #{friend_id}) OR " +
               "(user_id = #{friend_id} AND friend_id = #{user_id})")
        .first
  end

  def notify_friend_requester
    FriendRequestMailer.request_accepted(user, friend).deliver_later if is_confirmed
  end
end
