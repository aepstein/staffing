When /^I delete the (\d+)(?:st|nd|rd|th) period for #{capture_model}$/ do |pos, schedule|
  visit schedule_periods_url model schedule
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following periods:$/ do |expected_periods_table|
  expected_periods_table.diff!( tableish('table tr','td,th') )
end

