Then /^I should see the following periods:$/ do |table|
  table.diff! tableish( 'table#periods > tbody > tr', 'td' )
end

