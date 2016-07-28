class CreatePostalAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :state
      t.string :city
      t.string :zip
      t.integer :postal_addressable_id
      t.string :postal_addressable_type

      t.timestamps
    end
  end
end
