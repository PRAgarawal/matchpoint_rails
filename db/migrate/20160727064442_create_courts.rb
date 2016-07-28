class CreateCourts < ActiveRecord::Migration[5.0]
  ENUM_TYPES = {
      :court_type => %w('hard' 'clay' 'grass')
  }

  def self.up
    ENUM_TYPES.each do |type, values|
      values = values.join(", ")
      sql = "CREATE TYPE #{type} AS ENUM(#{values})"
      execute sql
    end

    create_table :courts do |t|
      t.string :name
      t.string :fee
      t.boolean :is_lighted
      t.boolean :is_public
      t.boolean :is_free
      t.string :phone
      t.integer :num_courts
      t.integer :min_users

      t.timestamps
    end

    add_column :courts, :court_type, :court_type
  end

  def self.down
    drop_table :courts

    ENUM_TYPES.each_key do |type|
      sql = "DROP TYPE #{type}"
      execute sql
    end
  end
end
