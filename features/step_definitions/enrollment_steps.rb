Then /^I should see the following enrollments:$/ do |table|
  table.diff! tableish( 'table#enrollments > tbody > tr', 'td' )
end

