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
    when /the new answer page/
      new_answer_path

    when /the new membership page/
      new_membership_path

    when /the new request page/
      new_request_path

    when /the new term page/
      new_term_path

    when /the new position page/
      new_position_path

    when /the new schedule page/
      new_schedule_path

    when /the new question page/
      new_question_path

    when /the new authority page/
      new_authority_path

    when /the new committee page/
      new_committee_path

    when /the new qualification page/
      new_qualification_path

    when /the new user page/
      new_user_path

    
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
