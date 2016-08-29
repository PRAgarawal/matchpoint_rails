class RemoveMatchTimeFromMatches < ActiveRecord::Migration[5.0]
  def change
    remove_column :matches, :match_time
  end
end
