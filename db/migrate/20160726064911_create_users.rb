class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.datetime :dob
      t.integer :skill
      t.boolean :is_male
      t.integer :home_court_id

      t.timestamps null: false
    end
  end
end
