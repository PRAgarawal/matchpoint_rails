module Friendable
  extend ActiveSupport::Concern

  def self.where_friend_clause(user_id)
    "id IN (
        SELECT friend_id FROM friend_links
        WHERE user_id = #{user_id} AND is_confirmed = true)"
  end
end
