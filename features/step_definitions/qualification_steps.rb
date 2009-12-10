When /^I delete the (\d+)(?:st|nd|rd|th) qualification$/ do |pos|
  visit qualifications_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following qualifications:$/ do |expected_qualifications_table|
  expected_qualifications_table.diff!( tableish('table tr','th,td') )
end

