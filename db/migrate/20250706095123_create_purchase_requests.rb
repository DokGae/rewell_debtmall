class CreatePurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :purchase_requests do |t|
      t.references :product, null: false, foreign_key: true
      t.string :buyer_name
      t.string :buyer_email
      t.string :buyer_phone
      t.decimal :offered_price
      t.text :message
      t.integer :status

      t.timestamps
    end
  end
end
