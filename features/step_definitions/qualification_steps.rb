Given /^the following qualifications:$/ do |qualifications|
  Qualification.create!(qualifications.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) qualification$/ do |pos|
  visit qualifications_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following qualifications:$/ do |expected_qualifications_table|
  expected_qualifications_table.diff!(table_at('table').to_a)
end
