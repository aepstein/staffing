When /^I delete the (\d+)(?:st|nd|rd|th) request for #{capture_model}$/ do |pos, position|
  visit position_requests_url model position
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following requests:$/ do |expected_requests_table|
  expected_requests_table.diff!( tableish('table tr','td,th') )
end

