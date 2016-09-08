class ChatMailer < ApplicationMailer
  def new_message(message)
    chat = message.chat
    @user_name = message.user.first_name
    @match_time = chat.match.match_date.strftime('%-l:%M %p %a, %-m/%-d')
    @match_court = chat.match.court.name
    @text = message.body
    emails = chat.users.pluck(:email).delete(message.user.email)

    mail(to: emails, subject: "New message from #{@user_name} about your match")
  end
end
