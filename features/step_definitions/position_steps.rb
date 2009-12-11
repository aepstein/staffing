When /^I delete the (\d+)(?:st|nd|rd|th) position$/ do |pos|
  visit positions_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following positions:$/ do |expected_positions_table|
  expected_positions_table.diff!( tableish('table tr','td,th') )
end

