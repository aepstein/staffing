Given /^the following positions:$/ do |positions|
  Position.create!(positions.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) position$/ do |pos|
  visit positions_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following positions:$/ do |expected_positions_table|
  expected_positions_table.diff!(table_at('table').to_a)
end
