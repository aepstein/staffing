Given /^I have a (current|recent|pending|past|future) (chair|vicechair|voter|clerk|nonvoter) relationship to the committee$/ do |tense, relationship|
  position = create :position
  create "#{tense}_membership".to_sym, position: position, user: @current_user
  case relationship
  when 'chair', 'vicechair'
    create :enrollment, roles: [ relationship ], committee: @committee, position: position
  when 'voter'
    create :enrollment, votes: 1, committee: @committee, position: position
  when 'clerk'
    create :enrollment, votes: 0, roles: [ relationship ], committee: @committee, position: position
  when 'nonvoter'
    create :enrollment, votes: 0, committee: @committee, position: position
  end
end

Given /^(?:an )authorization scenario of a committee to which I have an? (?:(current|recent|pending|past|future) )?(admin|staff|plain|chair|vicechair|voter|nonvoter) relationship$/ do |tense, relationship|
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @committee = create :committee
  case relationship
  when 'admin', 'staff', 'plain'
    nil
  else
    step %{I have a #{tense} #{relationship} relationship to the committee}
  end
end

Then /^I may( not)? see the committee$/ do |negate|
  visit(committee_url(@committee))
  step %{I should#{negate} be authorized}
  visit(committees_url)
  if negate.blank?
    expect( page ).to have_selector( "#committee-#{@committee.id}" )
  else
    expect( page ).to have_no_selector( "#committee-#{@committee.id}" )
  end
end

Then /^I may( not)? create committees$/ do |negate|
  Capybara.current_session.driver.submit :post, committees_url,
    { "committee" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_committee_url)
  step %{I should#{negate} be authorized}
  visit(committees_url)
  if negate.blank?
    expect( page ).to have_text('New committee')
  else
    expect( page ).to have_no_text('New committee')
  end
end

Then /^I may( not)? update the committee$/ do |negate|
  Capybara.current_session.driver.submit :put, committee_url(@committee),
    { "committee" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_committee_url(@committee))
  step %{I should#{negate} be authorized}
  visit(committees_url)
  if negate.blank?
    within("#committee-#{@committee.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the committee$/ do |negate|
  visit(committees_url)
  if negate.blank?
    within("#committee-#{@committee.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, committee_url(@committee), {}
  step %{I should#{negate} be authorized}
end

When /^I create an committee$/ do
  create :schedule, name: 'Annual'
  create :schedule, name: 'Semester'
  create :brand, name: 'Prestigious'
  create :brand, name: 'Silly'
  create :meeting_template, name: 'Informal'
  create :meeting_template, name: 'Elaborate'
  create :position, name: 'Member of Committee'
  visit(new_committee_path)
  fill_in "Name", with: "Important Committee"
  fill_in "Contact name", with: "Officials"
  fill_in "Contact email", with: "officials@example.com"
  select "Annual", from: "Schedule"
  select "Informal", from: "Meeting template"
  select "Prestigious", from: "Brand"
  fill_in "Publish email", with: "info@example.com"
  within_control_group('Active?') { choose 'No' }
  within_control_group('Sponsor?')  { choose 'Yes' }
  fill_in "Appoint message", with: "You will soon be in *committee*."
  fill_in "Join message", with: "Welcome to *committee*."
  fill_in "Leave message", with: "You were *dropped* from the committee."
  fill_in "Reject message", with: "There were *no* slots."
  click_link "Add Enrollment"
  fill_in "Position", with: "Member of Committee"
  fill_in "Title", with: "Voting Member"
  fill_in "Votes", with: "1"
  within_control_group("Requestable?") { choose 'Yes' }
  within_control_group("Roles") do
    check 'vicechair'
    check 'monitor'
  end
  click_button 'Create'
  @committee = Committee.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new committee$/ do
  within( ".alert" ) { expect( page ).to have_text( "Committee created." ) }
  within( "#committee-#{@committee.id}" ) do
    expect( page ).to have_text "Name: Important Committee"
    expect( page ).to have_text "Contact name: Officials"
    expect( page ).to have_text "Contact email: officials@example.com"
    expect( page ).to have_text "Active? No"
    expect( page ).to have_text "Sponsor? Yes"
    expect( page ).to have_text "Schedule: Annual"
    expect( page ).to have_text "Meeting template: Informal"
    expect( page ).to have_text "Brand: Prestigious"
    expect( page ).to have_text "Publish email: info@example.com"
    expect( page ).to have_text "You will soon be in committee."
    expect( page ).to have_text "Welcome to committee."
    expect( page ).to have_text "You were dropped from the committee."
    expect( page ).to have_text "There were no slots."
    expect( page ).to have_no_text "No enrollments."
    step %{I should see the following enrollments:}, table(%{
      | Member of Committee | Voting Member | 1 |
    })
    enrollment = @committee.enrollments.first
    within("tr#enrollment-#{enrollment.id}") do
      within("td:nth-of-type(4)") { expect( page ).to have_text "Yes" }
      within("td:nth-of-type(5)") { expect( page ).to have_text "vicechair, monitor" }
    end
  end
end

When /^I update the committee$/ do
  visit(edit_committee_path(@committee))
  fill_in "Name", with: "No Longer Important Committee"
  fill_in "Contact name", with: "Boss"
  fill_in "Contact email", with: "boss@example.com"
  within_control_group('Active?') { choose "Yes" }
  within_control_group('Sponsor?') { choose "No" }
  select "Semester", from: "Schedule"
  select "Elaborate", from: "Meeting template"
  select "Silly", from: "Brand"
  fill_in "Publish email", with: "info@example.org"
  fill_in "Appoint message", with: "Pre-welcome message"
  fill_in "Join message", with: "Welcome message"
  fill_in "Leave message", with: "Farewell message"
  fill_in "Reject message", with: "There were *not enough* slots."
  click_link "Remove Enrollment"
  click_button 'Update'
end

Then /^I should see the edited committee$/ do
  within('.alert') { expect( page ).to have_text( "Committee updated." ) }
  within("#committee-#{@committee.id}") do
    expect( page ).to have_text "Name: No Longer Important Committee"
    expect( page ).to have_text "Contact name: Boss"
    expect( page ).to have_text "Contact email: boss@example.com"
    expect( page ).to have_text "Active? Yes"
    expect( page ).to have_text "Sponsor? No"
    expect( page ).to have_text "Schedule: Semester"
    expect( page ).to have_text "Meeting template: Elaborate"
    expect( page ).to have_text "Brand: Silly"
    expect( page ).to have_text "Publish email: info@example.org"
    expect( page ).to have_text "Pre-welcome message"
    expect( page ).to have_text "Welcome message"
    expect( page ).to have_text "Farewell message"
    expect( page ).to have_text "There were not enough slots."
    expect( page ).to have_text 'No enrollments.'
  end
end

Given /^there are (\d+) committees$/ do |quantity|
  @committees = quantity.to_i.downto(1).
    map { |i| create :committee, name: "Committee #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) committee$/ do |text, committee|
  visit(committees_url)
  within("table > tbody > tr:nth-child(#{committee.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Committee destroyed.") }
end

Then /^I should see the following committees:$/ do |table|
  table.diff! tableish( 'table#committees > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for committees with name "([^"]+)"$/ do |needle|
  visit(committees_url)
  fill_in "Name", with: needle
  click_button "Search"
end

Given /^the committee is requestable to (any|undergrad|grad|student|no) status$/ do |status|
  @committee = create :committee
  case status
  when 'any'
    create :requestable_enrollment, committee: @committee,
      position: create(:position, statuses_mask: 0)
  when 'student'
    create :requestable_enrollment, committee: @committee,
      position: create(:position, statuses: %w( undergrad grad ))
  when 'no'
    create :enrollment, committee: @committee,
      position: create(:position, statuses_mask: 0)
  else
    create :requestable_enrollment, committee: @committee,
      position: create(:position, statuses: [ status ])
  end
end

Then /^I may( not)? request membership in the committee$/ do |negate|
  visit(root_url)
  within("#membership_requests") do
    if negate.blank?
      expect( page ).to have_text "You may browse 1 committee for which you are eligible to request membership."
    else
      expect( page ).to have_text "You may browse 0 committees for which you are eligible to request membership."
    end
  end
end

Given /^a report scenario of a committee to which I have a (?:(current|past|future) )?(admin|staff|chair|vicechair|voter|nonvoter|plain) relationship$/ do |tense, relationship|
  committee_relationship = case relationship
  when 'admin', 'staff', 'plain'
    nil
  when 'sponsor'
    'voter'
  else
    relationship
  end
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @committee = create :committee
  if committee_relationship
    step %{I have a #{tense} #{committee_relationship} relationship to the committee}
  end
  create :membership, position: create( :enrollment, committee: @committee ).position
end

When /^I download the (members (?:csv|pdf)|tents pdf|emplid pdf) report for the committee$/ do |type|
  VectorUploader.enable_processing = true
  create :brand
  VectorUploader.enable_processing = false
  case type
  when 'members csv'
    visit(committee_memberships_url(@committee, format: :csv))
  when 'members pdf'
    visit(members_committee_url(@committee, format: :pdf))
  when 'tents pdf'
    visit(tents_committee_url(@committee, format: :pdf))
  when 'emplid pdf'
    visit(empl_ids_committee_url(@committee, format: :pdf))
  end
end

