class AddPriceOfferFieldsToPurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_requests, :is_price_offer, :boolean, default: false
  end
end
