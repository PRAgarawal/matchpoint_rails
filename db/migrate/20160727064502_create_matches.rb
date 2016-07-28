class CreateMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :matches do |t|
      t.datetime :match_date
      t.integer :court_id
      t.boolean :is_singles
      t.boolean :is_friends_only

      t.timestamps
    end
  end
end
