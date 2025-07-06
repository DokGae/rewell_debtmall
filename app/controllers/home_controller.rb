class HomeController < ApplicationController
  def index
    @businesses = Business.active_businesses.includes(:logo_attachment)
  end
end
