class MakeIsMaleNotNull < ActiveRecord::Migration[5.0]
  def up
    execute 'UPDATE users SET is_male = true;'
    # Using `is_male` makes more sense from a coding standpoint, but it appears like it will cause too
    # many UI issue. So true if male, false if female
    rename_column :users, :is_male, :gender
  end

  def down
    rename_column :users, :gender, :is_male
  end
end
