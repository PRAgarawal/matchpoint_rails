class CreateFriendLinksView < ActiveRecord::Migration[5.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE VIEW friend_links AS
        SELECT user_id, friend_id, is_confirmed FROM friendships
        UNION
        SELECT friend_id, user_id, is_confirmed FROM friendships
    SQL
  end

  def down
    execute <<-SQL
      DROP VIEW friend_links
    SQL
  end
end
