class AddIsConfirmedToFriendships < ActiveRecord::Migration[5.0]
  def change
    add_column :friendships, :is_confirmed, :boolean, default: false
  end
end
