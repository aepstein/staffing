Given /^I (?:am )?log(?:ged)? in as "(.*)" with password "(.*)"$/ do |net_id, password|
  unless net_id.blank?
   visit login_url
   fill_in( 'Net', :with => net_id )
   fill_in( 'Password', :with => password )
   click_button( 'Login' )
   response.should contain('You logged in successfully.')
  end
end

Given /^I log in as #{capture_model}$/ do |user|
  Given %{I log in as "#{model(user).net_id}" with password "secret"}
end

When /^I log out$/ do
  When %{I go to the logout page}
end

