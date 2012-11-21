When /^I am on the home page$/ do
 visit root_url
end

Then /^I should (not )?see (any|the) committee in my voting committees$/ do |negate, specificity|
  if negate.blank?
    within("#voting_committees") do
      page.should have_selector "#committee-#{@committee.id}"
    end
  elsif specificity == 'any'
    page.should have_text 'You may not start motions for any committee at this time.'
  else
    within("#voting_committees") do
      page.should have_no_selector "#committee-#{@committee.id}"
    end
  end
end

