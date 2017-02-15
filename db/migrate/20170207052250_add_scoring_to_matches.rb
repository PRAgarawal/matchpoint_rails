class AddScoringToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :match_users, :is_winner, :boolean
    add_column :match_users, :set_1_total, :integer
    add_column :match_users, :set_2_total, :integer
    add_column :match_users, :set_3_total, :integer
  end
end
