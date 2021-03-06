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
    expect( page ).to have_selector( "#user-#{@user.id}" )
  else
    expect( page ).to have_no_selector( "#user-#{@user.id}" )
  end
end

Then /^I may( not)? create users$/ do |negate|
  Capybara.current_session.driver.submit :post, users_url,
    { "user" => { "first_name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_user_url)
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    expect( page ).to have_text('New user')
  else
    expect( page ).to have_no_text('New user')
  end
end

Then /^I may( not)? update the user$/ do |negate|
  Capybara.current_session.driver.submit :put, user_url(@user),
    { "user" => { "first_name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_user_url(@user))
  step %{I should#{negate} be authorized}
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { expect( page ).to have_text('Edit') }
  else
    if page.has_selector? "#user-#{@user.id}"
      within("#user-#{@user.id}") { expect( page ).to have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? set renewal preferences for the user$/ do |negate|
  visit renew_user_memberships_url @user
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit( :put,
    renew_user_memberships_url(@user),
    { "user" => { "renewal_checkpoint" => "0",
      "memberships_attributes" => Hash.new } } )
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? destroy the user$/ do |negate|
  visit(users_url)
  if negate.blank?
    within("#user-#{@user.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
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
    within_control_group("Administrator?") { expect( page ).to have_selector "input.disabled" }
    within_control_group("Staff?") { expect( page ).to have_selector "input.disabled" }
  end
  click_button 'Create'
  @user = User.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new user as (admin|staff)$/ do |role|
  within( ".alert" ) { expect( page ).to have_text( "User created." ) }
  within( "#user-#{@user.id}" ) do
    expect( page ).to have_text "First name: Andrew"
    expect( page ).to have_text "Middle name: D"
    expect( page ).to have_text "Last name: White"
    expect( page ).to have_text "Net id: fake"
    expect( page ).to have_text "Empl id: 123456"
    expect( page ).to have_text "Email: jd@example.com"
    expect( page ).to have_text "Mobile phone: (607) 555-1212"
    expect( page ).to have_text "Work phone: (607) 555-1234"
    expect( page ).to have_text "Home phone: (607) 555-4321"
    expect( page ).to have_text "Work address: 100 Day Hall"
    expect( page ).to have_text "Date of birth: June 4, 1982"
    expect( page ).to have_text "Resume? No"
    expect( page ).to have_text "Portrait: No"
    expect( page ).to have_text "Statuses: faculty"
    if role == 'admin'
      expect( page ).to have_text "Administrator? Yes"
      expect( page ).to have_text "Staff? Yes"
    else
      expect( page ).to have_text "Administrator? No"
      expect( page ).to have_text "Staff? No"
    end
  end
end

When /^I fill in the user as (admin|staff|owner)$/ do |role|
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
    within_control_group("Administrator?") { expect( page ).to have_selector "input.disabled" }
    within_control_group("Staff?") { expect( page ).to have_selector "input.disabled" }
  end
  if role == 'owner'
    within_control_group("Empl id") { expect( page ).to have_selector "input.disabled" }
    within_control_group("Status") { expect( page ).to have_selector "input.disabled" }
  else
    fill_in "Empl id", with: "654321"
    within_control_group("Status") { choose "staff" }
  end
end

When /^I update the user as (admin|staff|owner)$/ do |role|
  visit(edit_user_path(@user))
  step %{I fill in the user as #{role}}
  click_button 'Update'
end

When /^I register$/ do
  visit sso_register_path( provider: 'cornell', params: { sso_net_id: @net_id } )
  step %{I fill in the user as owner}
  click_button 'Register'
end

Then /^I should be registered$/ do
  expect( current_path ).to eql '/home'
  within(".alert") { expect( page ).to have_text "User registered." }
  within("h1") { expect( page ).to have_text "Welcome, David" }
end

Then /^I should see the edited user as (admin|staff|owner)$/ do |role|
  within('.alert') { expect( page ).to have_text( "User updated." ) }
  within("#user-#{@user.id}") do
    expect( page ).to have_text "First name: David"
    expect( page ).to have_text "Middle name: J"
    expect( page ).to have_text "Last name: Skorton"
    expect( page ).to have_text "Email: dj@example.com"
    expect( page ).to have_text "Mobile phone: (607) 555-1213"
    expect( page ).to have_text "Work phone: (607) 555-1235"
    expect( page ).to have_text "Home phone: (607) 555-4322"
    expect( page ).to have_text "101 Day Hall"
    expect( page ).to have_text "Date of birth: June 4, 1980"
    expect( page ).to have_text "Administrator? No"
    expect( page ).to have_text "Staff? No"
    if role == 'owner'
      expect( page ).to have_no_text "Empl id: 654321"
      expect( page ).to have_no_text "Statuses: staff"
    else
      expect( page ).to have_text "Empl id: 654321"
      expect( page ).to have_text "Statuses: staff"
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
  within(".alert") { expect( page ).to have_text("User destroyed.") }
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
  within(".alert") { expect( page ).to have_text "Processed empl_ids." }
  @user.reload
  expect( @user.empl_id ).to eql 123456
  expect( User.where { net_id.eq( 'faker2' ) } ).to be_empty
end

Given /^I have (?:an? )(#{User::STATUSES.join '|'}|no) status$/ do |status|
  @current_user.status = if status == 'no'
    nil
  else
    status
  end
  @current_user.save!
end

When /^I download the (tent pdf) report for the user$/ do |type|
  VectorUploader.enable_processing = true
  create :brand
  VectorUploader.enable_processing = false
  case type
  when 'tent pdf'
    visit(tent_user_url(@user, format: :pdf))
  end
end

