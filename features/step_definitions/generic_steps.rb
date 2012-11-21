Then /^I should not see the search field for a (\w+)$/ do |field|
  page.should have_no_fieldset field.titleize
end

