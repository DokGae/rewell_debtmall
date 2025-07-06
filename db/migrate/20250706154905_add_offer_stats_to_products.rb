class AddOfferStatsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :offer_count, :integer, default: 0
    add_column :products, :max_offer_price, :integer
  end
end
