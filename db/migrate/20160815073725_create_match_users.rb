class CreateMatchUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :match_users do |t|
      t.integer :match_id
      t.integer :user_id

      t.timestamps
    end

    add_index :match_users, [:user_id, :match_id], unique: true
  end
end
