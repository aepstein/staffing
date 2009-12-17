When /^I delete the (\d+)(?:st|nd|rd|th) enrollment for #{capture_model}$/ do |pos, enrollment|
  visit committee_enrollments_url model enrollment
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following enrollments:$/ do |expected_enrollments_table|
  expected_enrollments_table.diff!(tableish('table tr', 'td,th'))
end

