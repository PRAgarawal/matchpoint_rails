class AddIsConfirmedToCourts < ActiveRecord::Migration[5.0]
  def up
    add_column :courts, :is_confirmed, :boolean, default: false, null: false
    # Mark all currently existing courts as confirmed
    execute 'UPDATE courts SET is_confirmed = true;'
    add_column :courts, :requested_by_id, :integer
  end

  def down
    remove_column :courts, :is_confirmed
    remove_column :courts, :requested_by_id
  end
end
