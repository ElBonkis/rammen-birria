class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :price_with_discount, null: false, precision: 10, scale: 2
      t.integer :quantity, null: false
      t.decimal :subtotal, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
