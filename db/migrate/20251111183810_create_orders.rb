class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :address, null: false, foreign_key: true
      t.string :status
      t.integer :total_price
      t.integer :tax_amount
      t.string :stripe_customer_id
      t.string :stripe_payment_id

      t.timestamps
    end
  end
end
