Given /^I have a single sign on net id$/ do
  @net_id = 'zzz999'
  visit home_path( params: { sso_net_id: @net_id } )
end

Then /^I should be prompted to register$/ do
  within('.alert') { page.should have_text 'You must register to access this page.' }
end

Given /^I log in as the (admin|staff|plain) user$/ do |type|
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
  URI.parse(current_url).path.should eql '/'
  within '.alert' do
    page.should have_content "You logged in successfully."
  end
end

Then /^I can log out$/ do
  step %{I log out}
  URI.parse(current_url).path.should eql '/login'
  within '.alert' do
    page.should have_content "You logged out successfully."
  end
end

When /^the single sign on net id is associated with a user$/ do
  @current_user = create( :user, net_id: @net_id )
end

Then /^I should automatically log in when required$/ do
  visit edit_user_path( @current_user )
  current_path.should eql edit_user_path( @current_user )
end

