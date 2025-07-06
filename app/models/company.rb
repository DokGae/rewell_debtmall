# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_slug  (slug) UNIQUE
#

class Company < ApplicationRecord
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9가-힣-]+\z/, message: "는 문자, 숫자, 하이픈만 가능합니다" }
  
  before_validation :generate_slug_from_name
  
  def to_param
    slug
  end
  
  private
  
  def generate_slug_from_name
    if slug.blank? && name.present?
      # 한글, 영문, 숫자만 남기고 공백은 하이픈으로 변경
      base_slug = name.strip.gsub(/[^a-zA-Z0-9가-힣\s-]/, '').gsub(/\s+/, '-').downcase
      
      # 중복 체크 및 번호 추가
      if Company.exists?(slug: base_slug)
        count = 2
        while Company.exists?(slug: "#{base_slug}-#{count}")
          count += 1
        end
        self.slug = "#{base_slug}-#{count}"
      else
        self.slug = base_slug
      end
    end
  end
end
