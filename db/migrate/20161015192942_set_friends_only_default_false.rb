class SetFriendsOnlyDefaultFalse < ActiveRecord::Migration[5.0]
  def change
    change_column_default :matches, :is_friends_only, false
  end
end
