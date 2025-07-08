class Business::BaseController < ApplicationController
  before_action :authenticate_business!
  before_action :verify_business_access
  layout 'business'

  private

  def verify_business_access
    # URL의 slug와 현재 로그인한 업체가 일치하는지 확인
    if params[:business_slug].present?
      unless current_business.slug == params[:business_slug]
        redirect_to business_root_path, alert: "접근 권한이 없습니다."
      end
    end
  end

  def current_business_slug
    current_business&.slug
  end
  helper_method :current_business_slug
end