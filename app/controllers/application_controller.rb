class ApplicationController < ActionController::Base
  helper_method :review_scope
  protect_from_forgery

  is_authenticator
  has_breadcrumbs
  
  def force_sso
    super || Staffing::Application.app_config['force_sso']
  end

  def permission_denied
    redirect_to root_url, flash: { error: "You may not perform the requested action." }
  end
  
  def review_scope(controller, action)
    case action.to_s
    when 'assigned'
      current_user.reviewable_memberships.assigned
    when 'unassigned'
      current_user.reviewable_memberships.unassigned
    when 'renewable'
      current_user.renewable_memberships.unrenewed.renewal_undeclined
    when 'declined'
      current_user.renewable_memberships.renewal_declined
    end
  end
end

