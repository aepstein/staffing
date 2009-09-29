Given /^the following committees:$/ do |committees|
  Committee.create!(committees.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) committee$/ do |pos|
  visit committees_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following committees:$/ do |expected_committees_table|
  expected_committees_table.diff!(table_at('table').to_a)
end
