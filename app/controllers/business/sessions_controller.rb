class Business::SessionsController < Devise::SessionsController
  layout 'business_auth'
  
  before_action :configure_sign_in_params, only: [:create]
  before_action :set_business_from_slug, only: [:new]

  def new
    self.resource = resource_class.new(sign_in_params)
    store_location_for(resource, params[:redirect_to])
    super
  end

  def create
    # business_slug를 세션에 저장
    session[:business_slug] = params[:business_slug] if params[:business_slug].present?
    
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, location: after_sign_in_path_for(resource)
  end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:business_slug])
  end

  def set_business_from_slug
    @business_slug = params[:business_slug]
    @business = Business.friendly.find(@business_slug) if @business_slug.present?
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "업체를 찾을 수 없습니다."
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || business_root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    if params[:business_slug].present?
      business_login_path(business_slug: params[:business_slug])
    else
      root_path
    end
  end
end