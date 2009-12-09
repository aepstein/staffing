Given /^the following periods:$/ do |periods|
  Period.create!(periods.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) period$/ do |pos|
  visit periods_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following periods:$/ do |expected_periods_table|
  expected_periods_table.diff!(table_at('table').to_a)
end

