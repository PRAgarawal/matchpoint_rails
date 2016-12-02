class AddCourtCodeToCourts < ActiveRecord::Migration[5.0]
  def up
    add_column :courts, :court_code, :string
    Rake::Task[:initialize_court_codes].invoke
  end

  def down
    remove_column :courts, :court_code
  end
end
