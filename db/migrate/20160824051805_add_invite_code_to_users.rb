class AddInviteCodeToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :invite_code, :string, limit: 12, null: false, default: 'INIT'
    add_column :users, :invited_by_code, :string, limit: 12
    Rake::Task[:initialize_invite_codes].invoke
    add_index :users, :invite_code, unique: true
  end
end
