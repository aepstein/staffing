When /^I delete the (\d+)(?:st|nd|rd|th) committee$/ do |pos|
  visit committees_url
  within("table > tbody > tr:nth-child(#{pos.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following committees:$/ do |expected_committees_table|
  expected_committees_table.diff!( tableish( 'table tr', 'td,th' ) )
end

