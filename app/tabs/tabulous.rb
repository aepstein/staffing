Tabulous.setup do
  tabs do
    home_tab do
      text { 'Home' }
      link_path { home_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('home') }
    end
    admin_tab do
      text { 'Administration' }
      link_path { users_path }
      visible_when { permitted_to?( :staff, :users ) }
      enabled_when { true }
      active_when do
        a_subtab_is_active
        in_action('any').of_controller('memberships')
      end
    end
    authorities_subtab do
      text { 'Authorities' }
      link_path { authorities_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('authorities') }
    end
    brands_subtab do
      text { 'Brands' }
      link_path { brands_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('brands') }
    end
    positions_subtab do
      text { 'Positions' }
      link_path { positions_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('positions') }
    end
    committees_subtab do
      text { 'Committees' }
      link_path { committees_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('committees') }
    end
    meeting_templates_subtab do
      text { 'Meeting Templates' }
      link_path { meeting_templates_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('meeting_templates') }
    end
    users_subtab do
      text { 'Users' }
      link_path { users_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('users') }
    end
    questions_subtab do
      text { 'Questions' }
      link_path { questions_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('questions') }
    end
    quizzes_subtab do
      text { 'Quizzes' }
      link_path { quizzes_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('quizzes') }
    end
    schedules_subtab do
      text { 'Schedules' }
      link_path { schedules_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('schedules') }
    end
    meetings_subtab do
      text { 'Meetings' }
      link_path { meetings_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('meetings') }
    end
    motions_subtab do
      text { 'Motions' }
      link_path { motions_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('any').of_controller('motions') }
    end
    review_tab do
      text { 'Review' }
      link_path { reviewable_memberships_path }
      visible_when { current_user && current_user.authorities.prospective.any? }
      enabled_when { true }
      active_when { a_subtab_is_active }
    end
    active_memberships_subtab do
      text { 'Active Memberships' }
      link_path { active_reviewable_memberships_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('active').of_controller('review/memberships') }
    end
    active_membership_requests_subtab do
      text { 'Active Membership Requests' }
      link_path { active_reviewable_membership_requests_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('active').of_controller('review/membership_requests') }
    end
    inactive_membership_requests_subtab do
      text { 'Inactive Membership Requests' }
      link_path { inactive_reviewable_membership_requests_path }
      visible_when { true }
      enabled_when { true }
      active_when { in_action('inactive').of_controller('review/membership_requests') }
    end
    logout_tab do
      text { 'Log Out' }
      link_path { logout_path }
      visible_when { current_user.present? }
      enabled_when { true }
      active_when { in_actions('destroy').of_controller('user_sessions') }
    end
    login_tab do
      text { 'Log In' }
      link_path { force_sso ? sso_login_path( provider: force_sso ) : login_path }
      visible_when { current_user.blank? }
      enabled_when { true }
      active_when { in_actions('new','create').of_controller('user_sessions') }
    end
  end

  customize do
    active_tab_clickable true
#    always_render_subtabs false
    when_action_has_no_tab :raise_error
    renderer :bootstrap_pill
#    html5 false
#    tabs_ul_class "nav nav-pills"
#    bootstrap_style_subtabs true
  end
end

