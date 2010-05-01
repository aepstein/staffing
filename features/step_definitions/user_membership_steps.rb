Given /^the following user_memberships:$/ do |user_memberships|
  UserMembership.create!(user_memberships.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) user_membership$/ do |pos|
  visit user_memberships_url
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following user_memberships:$/ do |expected_user_memberships_table|
  expected_user_memberships_table.diff!(tableish('table tr', 'td,th'))
end
