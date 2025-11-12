class AddIdToCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :categories, :id, :primary_key unless column_exists?(:categories, :id)
  end
end
