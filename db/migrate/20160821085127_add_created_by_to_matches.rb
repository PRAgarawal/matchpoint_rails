class AddCreatedByToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :created_by_id, :integer, required: true
    add_column :users, :is_admin, :boolean, default: false
  end
end
