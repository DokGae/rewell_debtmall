class MakeBuyerEmailOptionalInPurchaseRequests < ActiveRecord::Migration[8.0]
  def change
    # buyer_email은 이미 null 허용이므로 별도 작업 불필요
    # 이 마이그레이션은 문서화 목적으로만 유지
  end
end
