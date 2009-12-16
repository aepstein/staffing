When /^I delete the (\d+)(?:st|nd|rd|th) membership for #{capture_model}$/ do |pos, position|
  visit position_memberships_url model position
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following memberships:$/ do |expected_memberships_table|
  expected_memberships_table.diff!( tableish('table tr','th,td') )
end

