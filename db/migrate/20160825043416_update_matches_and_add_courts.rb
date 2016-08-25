class UpdateMatchesAndAddCourts < ActiveRecord::Migration[5.0]
  def up
    # add_column :matches, :match_time, :integer, default: 0, null: false
    # change_column :matches, :is_singles, :boolean, null: false, default: false
    # change_column :matches, :is_friends_only, :boolean, null: false, default: true
    # change_column :matches, :match_date, :datetime, null: false
    add_column :courts, :location_type, :string
    rename_table :addresses, :postal_addresses
    Rake::Task[:create_initial_courts].invoke
  end

  def down
  end
end
