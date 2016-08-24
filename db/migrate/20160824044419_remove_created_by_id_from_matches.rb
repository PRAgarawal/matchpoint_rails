class RemoveCreatedByIdFromMatches < ActiveRecord::Migration[5.0]
  def change
    remove_column :matches, :created_by_id
  end
end
