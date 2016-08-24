class Friendship < ApplicationRecord
  attr_accessor :invite_code
  attr_accessor :email

  before_create :set_attributes

  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  def set_attributes
    user = nil
    if invite_code.present?
      user = User.find_by(invite_code: invite_code)
    elsif email.present?
      user = User.find_by(email: email)
    end
    self.user_id = User.current_user.id
    self.friend_id = user.try(:id)
  end
end
