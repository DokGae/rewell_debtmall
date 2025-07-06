class CompaniesController < ApplicationController
  before_action :set_company
  
  def show
    # 여기에 회사 페이지 로직 추가
  end
  
  private
  
  def set_company
    @company = Company.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "회사를 찾을 수 없습니다."
  end
end
