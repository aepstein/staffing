Given /^the following schedules:$/ do |schedules|
  Schedule.create!(schedules.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) schedule$/ do |pos|
  visit schedules_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following schedules:$/ do |expected_schedules_table|
  expected_schedules_table.diff!(table_at('table').to_a)
end
