class CreateBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :email
      t.string :phone
      t.text :address
      t.decimal :total_debt
      t.integer :status

      t.timestamps
    end
    add_index :businesses, :slug, unique: true
  end
end
