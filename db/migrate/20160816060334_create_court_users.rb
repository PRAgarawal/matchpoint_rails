class CreateCourtUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :court_users do |t|
      t.integer :court_id
      t.integer :user_id

      t.timestamps
    end

    add_index :court_users, [:user_id, :court_id], unique: true
  end
end
