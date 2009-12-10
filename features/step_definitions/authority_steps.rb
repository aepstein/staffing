When /^I delete the (\d+)(?:st|nd|rd|th) authority$/ do |pos|
  visit authorities_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following authorities:$/ do |expected_authorities_table|
  expected_authorities_table.diff!( tableish('table tr','td,th') )
end

