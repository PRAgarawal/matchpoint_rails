class ChatMailer < ApplicationMailer
  def self.new_messages(message)
    emails = message.chat.users.pluck(:email)
    emails.delete(message.user.email)

    emails.each { |email|
      ChatMailer.new_message(message, email).deliver_later
    }
  end

  def new_message(message, recipient)
    chat = message.chat
    @user_name = message.user.first_name
    @match_time = chat.match.match_date.strftime('%-l:%M %p %a, %-m/%-d')
    @match_court = chat.match.court.name
    @text = message.body

    mail(to: recipient, subject: "New message from #{@user_name} about your match")
  end
end
