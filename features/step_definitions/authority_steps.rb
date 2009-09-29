Given /^the following authorities:$/ do |authorities|
  Authority.create!(authorities.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) authority$/ do |pos|
  visit authorities_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following authorities:$/ do |expected_authorities_table|
  expected_authorities_table.diff!(table_at('table').to_a)
end
