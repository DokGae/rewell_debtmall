class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :original_price
      t.decimal :sale_price
      t.string :category
      t.integer :status
      t.boolean :featured
      t.integer :stock_quantity
      t.text :specifications

      t.timestamps
    end
  end
end
