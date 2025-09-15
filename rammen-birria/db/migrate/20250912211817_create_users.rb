class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :jti

      t.timestamps
    end
    add_index :users, :email
    add_index :users, :jti
  end
end
