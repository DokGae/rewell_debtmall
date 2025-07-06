class AddCategoryIdToProducts < ActiveRecord::Migration[8.0]
  def change
    add_reference :products, :category, null: true, foreign_key: true
    add_column :products, :image_positions, :text
  end
end
