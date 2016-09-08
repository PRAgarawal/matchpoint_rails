class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates :body, presence: true, length: {maximum: 1000}

  after_create :send_notification_email

  def send_notification_email
    ChatMailer.new_message(self).deliver_later
  end
end
