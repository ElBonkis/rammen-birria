class AddTokenVersionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :token_version, :integer
  end
end
