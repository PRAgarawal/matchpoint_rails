class MatchUser < ApplicationRecord
  belongs_to :match
  belongs_to :user

  before_destroy :destroy_match_if_last
  after_create :create_chat_user

  def destroy_match_if_last
    match.destroy! if match.users.count == 1
  end
  
  def create_chat_user
    ChatUser.create!(chat_id: match.chat.id, user_id: self.user_id)
  end
end
