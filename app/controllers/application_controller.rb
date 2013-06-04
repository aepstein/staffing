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
    case controller.to_s
    when 'memberships'
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
    when 'membership_requests'
      case action.to_s
      when 'active'
        current_user.reviewable_membership_requests.active
      when 'inactive'
        current_user.reviewable_membership_requests.inactive
      end
    end
  end
end

