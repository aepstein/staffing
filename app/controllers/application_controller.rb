class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator
  has_breadcrumbs
  
  def force_sso
    super || Staffing::Application.app_config['force_sso']
  end

  def permission_denied
    redirect_to root_url, flash: { error: "You may not perform the requested action." }
  end
end

