Given /^the following requests:$/ do |requests|
  Request.create!(requests.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) request$/ do |pos|
  visit requests_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following requests:$/ do |expected_requests_table|
  expected_requests_table.diff!(table_at('table').to_a)
end
