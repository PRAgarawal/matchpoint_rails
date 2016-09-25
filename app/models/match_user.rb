class MatchUser < ApplicationRecord
  belongs_to :match
  belongs_to :user

  before_destroy :destroy_match_if_last, :destroy_chat_user, :send_match_left_email
  after_create :create_chat_user, :send_match_joined_email

  def destroy_match_if_last
    match.destroy! if match.users.count == 1
  end

  def destroy_chat_user
    ChatUser.where(chat_id: match.chat.id, user_id: user.id).destroy_all
  end
  
  def create_chat_user
    ChatUser.create!(chat_id: match.chat.id, user_id: self.user_id)
  end

  def send_match_joined_email
    MatchMailer.joined_match(user, match)
  end

  def send_match_left_email
    MatchMailer.left_match(user, match)
  end
end
