class AddMoreScoringToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :match_users, :set_4_total, :integer
    add_column :match_users, :set_5_total, :integer
  end
end
