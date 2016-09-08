class AddChatsToMatches < ActiveRecord::Migration[5.0]
  def change
    Rake::Task[:add_chats_to_matches].invoke
  end
end
