class Chat < ApplicationRecord
  has_many :messages
  has_many :chat_users, dependent: :destroy
  has_many :users, through: :chat_users
  belongs_to :match
end
