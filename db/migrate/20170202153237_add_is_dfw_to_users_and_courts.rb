class AddIsDfwToUsersAndCourts < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_dfw, :boolean, default: true
    add_column :courts, :is_dfw, :boolean, default: true
  end
end
