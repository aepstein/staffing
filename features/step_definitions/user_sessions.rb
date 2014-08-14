Given /^I have a single sign on net id$/ do
  @net_id = 'zzz999'
end

When /^I try to log in with the single sign on$/ do
  visit sso_login_path( provider: 'cornell', params: { sso_net_id: @net_id } )
end

Then /^I should be prompted to register$/ do
  within('.alert') { expect( page ).to have_text 'You must register to access this page.' }
end

Given /^I log in as the (admin|staff|plain) user$/ do |type|
  @role = case type
  when 'admin', 'staff'
    type
  else
    'user'
  end
  @current_user = case type
  when 'admin'
    create :user, admin: true, first_name: "Senior", last_name: "Administrator"
  when 'staff'
    create :user, staff: true
  else
    create :user
  end
  step %{I log in with net_id: "#{@current_user.net_id}" and password: "secret"}
end

Given /^I log in with net_id: "(.+)" and password: "(.+)"$/ do |username, password|
  visit login_path
  fill_in 'Net Id', with: username
  fill_in 'Password', with: password
  click_button 'Log in'
  @current_user = User.find_by_net_id(username) unless @current_user && @current_user.net_id == username
end

Given /^I log out$/ do
  visit logout_path
end

Then /^I should be logged in$/ do
  expect( URI.parse(current_url).path ).to eql '/'
  within '.alert' do
    expect( page ).to have_content "You logged in successfully."
  end
end

Then /^I can log out$/ do
  step %{I log out}
  expect( URI.parse(current_url).path ).to eql '/login'
  within '.alert' do
    expect( page ).to have_content "You logged out successfully."
  end
end

When /^the single sign on net id is associated with a user$/ do
  @current_user = create( :user, net_id: @net_id )
end

When /^I follow the log in link with forced single sign on$/ do
  visit home_path( params: { force_sso: 'cornell' } )
  click_link "Log In"
end

#Then /^I should automatically log in$/ do
#  expect( page ).to have_text "Welcome, #{@current_user.first_name}"
#end

