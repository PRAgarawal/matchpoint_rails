class UpdateCourts < ActiveRecord::Migration[5.0]
  def up
    add_column :courts, :location_type, :string
    rename_table :addresses, :postal_addresses
  end

  def down
  end
end
