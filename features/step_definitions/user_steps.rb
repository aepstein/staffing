Given /^(?:an )authorization scenario of a user to which I have an? (admin|staff|authority|authority_ro|owner|plain) relationship$/ do |relationship|
  role = case relationship
  when 'admin'
    'admin'
  when 'staff'
    'staff'
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  case relationship
  when 'authority'
    membership = create( :membership )
    membership.position.authority.committee = create( :committee )
    membership.position.authority.save!
    create( :membership, user: @current_user, position: create( :enrollment,
      committee: membership.position.authority.committee, votes: 1 ).position )
    @user = membership.user
  when 'authority_ro'
    membership = create( :membership )
    membership.position.authority.committee = create( :committee )
    membership.position.authority.save!
    create( :membership, user: @current_user, position: create( :enrollment,
      committee: membership.position.authority.committee, votes: 0 ).position )
    @user = membership.user
  when 'owner'
    @user = @current_user
  else
    @user = create( :user )
  end
end

Then /^I may( not)? see the user$/ do |negate|
  visit(user_url(@user))
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    page.should have_selector( "#user-#{@user.id}" )
  else
    page.should have_no_selector( "#user-#{@user.id}" )
  end
end

Then /^I may( not)? create users$/ do |negate|
  Capybara.current_session.driver.submit :post, users_url, {}
  step %{I should#{negate} be authorized}
  visit(new_user_url)
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    page.should have_text('New user')
  else
    page.should have_no_text('New user')
  end
end

Then /^I may( not)? update the user$/ do |negate|
  Capybara.current_session.driver.submit :put, user_url(@user), {}
  step %{I should#{negate} be authorized}
  visit(edit_user_url(@user))
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { page.should have_text('Edit') }
  else
    if page.has_selector? "#user-#{@user.id}"
      within("#user-#{@user.id}") { page.should have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? set renewal preferences for the user$/ do |negate|
  visit renew_user_memberships_url @user
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit :put, renew_user_memberships_url(@user), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? destroy the user$/ do |negate|
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, user_url(@user), {}
  step %{I should#{negate} be authorized}
end

When /^I create a user as (admin|staff)$/ do |role|
  visit(new_user_path)
  fill_in "First name", with: "Andrew"
  fill_in "Middle name", with: "D"
  fill_in "Last name", with: "White"
  fill_in "Net id", with: "fake"
  fill_in "Empl id", with: "123456"
  within_control_group("Status") { choose "faculty" }
  fill_in "Email", with: "jd@example.com"
  fill_in "Mobile phone", with: "607-555-1212"
  fill_in "Work phone", with: "607-555-1234"
  fill_in "Home phone", with: "607-555-4321"
  fill_in "Work address", with: "100 Day Hall"
  fill_in "Date of birth", with: "1982-06-04"
  if role == 'admin'
    within_control_group("Administrator?") { choose "Yes" }
    within_control_group("Staff?") { choose "Yes" }
  else
    page.should have_no_control_group("Administrator?")
    page.should have_no_control_group("Staff?")
  end
  click_button 'Create'
  @user = User.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new user as (admin|staff)$/ do |role|
  within( ".alert" ) { page.should have_text( "User created." ) }
  within( "#user-#{@user.id}" ) do
    page.should have_text "First name: Andrew"
    page.should have_text "Middle name: D"
    page.should have_text "Last name: White"
    page.should have_text "Net id: fake"
    page.should have_text "Empl id: 123456"
    page.should have_text "Email: jd@example.com"
    page.should have_text "Mobile phone: (607) 555-1212"
    page.should have_text "Work phone: (607) 555-1234"
    page.should have_text "Home phone: (607) 555-4321"
    page.should have_text "Work address: 100 Day Hall"
    page.should have_text "Date of birth: June 4, 1982"
    page.should have_text "Resume? No"
    page.should have_text "Portrait: No"
    page.should have_text "Statuses: faculty"
    if role == 'admin'
      page.should have_text "Administrator? Yes"
      page.should have_text "Staff? Yes"
    else
      page.should have_text "Administrator? No"
      page.should have_text "Staff? No"
    end
  end
end

When /^I update the user as (admin|staff|owner)$/ do |role|
  visit(edit_user_path(@user))
  fill_in "First name", with: "David"
  fill_in "Middle name", with: "J"
  fill_in "Last name", with: "Skorton"
  fill_in "Email", with: "dj@example.com"
  fill_in "Mobile phone", with: "607-555-1213"
  fill_in "Work phone", with: "607-555-1235"
  fill_in "Home phone", with: "607-555-4322"
  fill_in "Work address", with: "101 Day Hall"
  fill_in "Date of birth", with: "1980-06-04"
  if role == 'admin'
    within_control_group("Administrator?") { choose "No" }
    within_control_group("Staff?") { choose "No" }
  else
    page.should have_no_control_group("Administrator?")
    page.should have_no_control_group("Staff?")
  end
  if role == 'owner'
    page.should have_no_control_group("Empl id")
    page.should have_no_control_group("Status")
  else
    fill_in "Empl id", with: "654321"
    within_control_group("Status") { choose "staff" }
  end
  click_button 'Update'
end

Then /^I should see the edited user as (admin|staff|owner)$/ do |role|
  within('.alert') { page.should have_text( "User updated." ) }
  within("#user-#{@user.id}") do
    page.should have_text "First name: David"
    page.should have_text "Middle name: J"
    page.should have_text "Last name: Skorton"
    page.should have_text "Email: dj@example.com"
    page.should have_text "Mobile phone: (607) 555-1213"
    page.should have_text "Work phone: (607) 555-1235"
    page.should have_text "Home phone: (607) 555-4322"
    page.should have_text "101 Day Hall"
    page.should have_text "Date of birth: June 4, 1980"
    page.should have_text "Administrator? No"
    page.should have_text "Staff? No"
    if role == 'owner'
      page.should have_no_text "Empl id: 654321"
      page.should have_no_text "Statuses: staff"
    else
      page.should have_text "Empl id: 654321"
      page.should have_text "Statuses: staff"
    end
  end
end

Given /^there are (\d+) users$/ do |quantity|
  @users = quantity.to_i.downto(1).
    map { |i| create :user, first_name: "Sequenced3#{i+2}", last_name: "User 1#{i}", net_id: "faker2#{i+1}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) user$/ do |text, user|
  visit(users_url)
  within("table > tbody > tr:nth-child(#{user.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { page.should have_text("User destroyed.") }
end

Then /^I should see the following users:$/ do |table|
  table.diff! tableish( 'table#users > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for users with name "([^"]+)"$/ do |needle|
  visit(users_url)
  fill_in "Name", with: needle
  click_button "Search"
end

When /^I set empl_ids in bulk via (text|attachment)$/ do |method|
  @user = create(:user, net_id: 'faker1')
  visit(import_empl_id_users_url)
  values = [ %w( faker1 123456 ), %w( faker2 123457 ) ]
  path = "#{temporary_file_path}/users.csv"
  if method == 'text'
    fill_in 'users', with: CSV.generate { |csv| values.each { |v| csv << v } }
  else
    file = CSV.open("#{temporary_file_path}/users.csv",'w') do |csv|
      values.each { |v| csv << v }
      csv
    end
    $temporary_files << file
    attach_file "users_file", file.path
  end
  click_button "Import empl_ids"
end

Then /^I should see empl_ids set$/ do
  within(".alert") { page.should have_text "Processed empl_ids." }
  @user.reload
  @user.empl_id.should eql 123456
  User.where { net_id.eq( 'faker2' ) }.should be_empty
end

Given /^I have (?:an? )(#{User::STATUSES.join '|'}|no) status$/ do |status|
  @current_user.status = if status == 'no'
    nil
  else
    status
  end
  @current_user.save!
end

