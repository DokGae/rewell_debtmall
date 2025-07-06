class SetDefaultStatusForPurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    # Update existing nil status to pending
    PurchaseRequest.where(status: nil).update_all(status: 0)
    
    # Set default value for status column
    change_column_default :purchase_requests, :status, from: nil, to: 0
  end
end
