class UpdateMatches < ActiveRecord::Migration[5.0]
  def up
    add_column :matches, :match_time, :integer, default: 0, null: false
    change_column :matches, :is_singles, :boolean, null: false, default: false
    change_column :matches, :is_friends_only, :boolean, null: false, default: true
    change_column :matches, :match_date, :datetime, null: false
  end

  def down
  end
end
