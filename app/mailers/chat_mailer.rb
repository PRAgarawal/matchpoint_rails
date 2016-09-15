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
    match = chat.match
    @user_name = message.user.first_name
    @match_time = match.match_date.strftime('%-l:%M %p %a, %-m/%-d')
    @match_court = match.court.name
    @text = message.body
    @url_ext = chat.id.to_s + '/' + match.id.to_s

    mail(to: recipient, subject: "New message from #{@user_name} about your match")
  end
end
