module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the homepage/
      '/'
    when /the new user_mailer page/
      new_user_mailer_path

    when /the new committee_membership page/
      new_committee_membership_path

    when /the new user_membership page/
      new_user_membership_path


    when /the login page/
      login_path

    when /the logout page/
      logout_path

    when /^the edit page for #{capture_model}$/
      edit_polymorphic_path( [model($1)] )

    when /^the new #{capture_factory} page$/
      new_polymorphic_path( [$1] )

    when /^the new #{capture_factory} page for #{capture_model}$/
      new_polymorphic_path( [model($2), $1] )

    when /^the(?: (\w+))? #{capture_plural_factory} page$/
      $1 ? polymorphic_path( [$1, $2] ) : polymorphic_path( [$2] )

    when /^the(?: (\w+))? #{capture_plural_factory} page for #{capture_model}$/
      $1 ? polymorphic_path( [$1, model($3), $2] ) : polymorphic_path( [model($3), $2] )

    when /^the page for #{capture_model}$/
      polymorphic_path( [model($1)] )



    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)

