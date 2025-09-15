class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.string :code, null: false
      t.integer :status, null: false, default: 0
      t.string :customer_name, null: false
      t.string :customer_phone, null: false
      t.string :customer_address
      t.integer :delivery_method, null: false, default: 0
      t.integer :payment_method, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :orders, :code, unique: true
  end
end
