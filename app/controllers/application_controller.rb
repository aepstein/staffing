class ApplicationController < ActionController::Base
  protect_from_forgery

  is_authenticator
  has_breadcrumbs

  def permission_denied
    redirect_to root_url, flash: { error: "You may not perform the requested action." }
  end
end

