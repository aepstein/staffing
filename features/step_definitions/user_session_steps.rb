Given /^I logged in as the administrator$/ do
  Given %{a user exists with password: "secret", net_id: "admin", admin: true}
  And %{I logged in as "admin" with password "secret"}
end

Given /^I logged in as "(\w+)" with password "(\w+)"$/ do |net_id, password|
  When %{I go to the login page}
  And %{I fill in "Username" with "#{net_id}"}
  And %{I fill in "Password" with "#{password}"}
  And %{I press "Login"}
  Then %{I should see "You logged in successfully."}
end

When /^I log out$/ do
  When %{I go to the logout page}
end

