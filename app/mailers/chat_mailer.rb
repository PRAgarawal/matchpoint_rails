class ChatMailer < ApplicationMailer
  def self.new_messages(message)
    message.chat.users.each { |user|
      ChatMailer.new_message(message, user).deliver_later if user.id != message.user.id
    }
  end

  def new_message(message, recipient)
    chat = message.chat
    match = chat.match
    @sender_name = message.user.first_name
    @recipient_name = recipient.first_name
    @match_time = match.formatted_match_date
    @match_type = match.is_singles ? 'Singles' : 'Doubles'
    @text = message.body
    @url_ext = chat.id.to_s + '/' + match.id.to_s

    mail(to: recipient.email, subject: "Update to your #{match.is_singles ? 'singles' : 'doubles'} match on #{match.formatted_match_date}")
  end
end
