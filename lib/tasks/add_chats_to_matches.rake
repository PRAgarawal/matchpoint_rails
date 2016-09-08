desc 'Add a chat record associated with every existing Match'
task :add_chats_to_matches => :environment do
  Match.all.each do |match|
    chat = Chat.create!(match_id: match.id)
    match.match_users.each do |match_user|
      ChatUser.create!(chat_id: chat.id, user_id: match_user.user_id)
    end
  end
end
