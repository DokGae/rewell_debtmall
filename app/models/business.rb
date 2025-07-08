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
#  deadline    :datetime
#
# Indexes
#
#  index_businesses_on_slug  (slug) UNIQUE
#

class Business < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  devise :database_authenticatable, :recoverable, 
         :rememberable, :trackable, :validatable

  has_many :products, dependent: :destroy
  has_one_attached :logo

  enum :status, { active: 0, inactive: 1, closed: 2 }

  validates :name, presence: true, uniqueness: true
  validates :phone, presence: true
  validates :total_debt, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :password, presence: true, on: :update, if: :encrypted_password_changed?

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
  
  def deadline_active?
    deadline.present? && deadline > Time.current
  end
  
  def deadline_expired?
    deadline.present? && deadline <= Time.current
  end
  
  def time_until_deadline
    return nil unless deadline_active?
    deadline - Time.current
  end
  
  def days_until_deadline
    return nil unless deadline_active?
    ((deadline - Time.current) / 1.day).floor
  end
  
  def hours_until_deadline
    return nil unless deadline_active?
    ((deadline - Time.current) / 1.hour).floor % 24
  end
  
  def minutes_until_deadline
    return nil unless deadline_active?
    ((deadline - Time.current) / 1.minute).floor % 60
  end
  
  def seconds_until_deadline
    return nil unless deadline_active?
    ((deadline - Time.current) / 1.second).floor % 60
  end
  
  def status_text
    I18n.t("enums.business.status.#{status}")
  end
  
  def self.status_options
    statuses.map { |key, _| [I18n.t("enums.business.status.#{key}"), key] }
  end

  def active_for_authentication?
    super && status == 'active'
  end

  def inactive_message
    status == 'active' ? super : :account_inactive
  end
end
