class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name
      t.string :description
      t.integer :price
      t.integer :quantity_in_stock
      t.boolean :on_sale

      t.timestamps
    end
  end
end
