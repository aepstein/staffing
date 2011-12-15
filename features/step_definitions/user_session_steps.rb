Given /^I (?:am )?log(?:ged)? in as "(.*)" with password "(.*)"$/ do |net_id, password|
  unless net_id.blank?
   step %{I am on the login page}
   step %{I fill in "Net" with "#{net_id}"}
   step %{I fill in "Password" with "#{password}"}
   step %{I press "Login"}
   step %{I should see "You logged in successfully."}
  end
end

Given /^I log in as #{capture_model}$/ do |user|
  step %{I log in as "#{model(user).net_id}" with password "secret"}
end

When /^I log out$/ do
  step %{I go to the logout page}
end

