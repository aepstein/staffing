When /^I am on the home page$/ do
 visit root_url
end

Then /^I should (not )?see (any|the) committee in my voting committees$/ do |negate, specificity|
  if negate.blank?
    within("#voting_committees") do
      expect( page ).to have_selector "#committee-#{@committee.id}"
    end
  elsif specificity == 'any'
    expect( page ).to have_text 'You may not start motions for any committee at this time.'
  else
    within("#voting_committees") do
      expect( page ).to have_no_selector "#committee-#{@committee.id}"
    end
  end
end

Then /^I should (not )?see (any|the) membership_request in my active membership requests$/ do |negate, specificity|
  if negate.blank?
    within("#membership-requests") do
      expect( page ).to have_selector "#membership-request-#{@membership_request.id}"
    end
  elsif specificity == 'any'
    expect( page ).to have_text 'No membership requests.'
  else
    within("#membership-requests") do
      expect( page ).to have_no_selector "#membership-request-#{@membership_request.id}"
    end
  end
end

When /^I go to my meetings dashboard$/ do
  visit home_path
  within(".nav-tabs") { click_link "Meetings" }
end

When /^I go to my motions dashboard$/ do
  visit home_path
  within(".nav-tabs") { click_link "Motions" }
end

