Then /^I should not see the search field for a (\w+)$/ do |field|
  expect( page ).to have_no_fieldset field.titleize
end

