Given /^I (?:am )?log(?:ged)? in as "(.*)" with password "(.*)"$/ do |net_id, password|
  unless net_id.blank?
   Given %{I am on the login page}
   When %{I fill in "Net" with "#{net_id}"}
   When %{I fill in "Password" with "#{password}"}
   When %{I press "Login"}
   Then %{I should see "You logged in successfully."}
  end
end

Given /^I log in as #{capture_model}$/ do |user|
  Given %{I log in as "#{model(user).net_id}" with password "secret"}
end

When /^I log out$/ do
  When %{I go to the logout page}
end

