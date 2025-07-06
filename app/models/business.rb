# == Schema Information
#
# Table name: businesses
#
#  id          :integer          not null, primary key
#  name        :string
#  slug        :string
#  description :text
#  email       :string
#  phone       :string
#  address     :text
#  total_debt  :decimal(, )
#  status      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_businesses_on_slug  (slug) UNIQUE
#

class Business < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  has_many :products, dependent: :destroy
  has_one_attached :logo

  enum :status, { active: 0, inactive: 1, closed: 2 }

  validates :name, presence: true, uniqueness: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true
  validates :total_debt, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active_businesses, -> { where(status: :active) }
  
  def slug_candidates
    [
      :name,
      [:name, :id]
    ]
  end
  
  def normalize_friendly_id(text)
    text.to_s.downcase.strip
      .gsub(/[^a-zA-Z0-9가-힣\s-]/, '') # 한글, 영문, 숫자, 공백, 하이픈만 허용
      .gsub(/\s+/, '-') # 공백을 하이픈으로 변경
  end
end
