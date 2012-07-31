class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator
  has_breadcrumbs

  def permission_denied
    redirect_to root_url, alert: "You are not allowed to perform the requested action."
  end
end

