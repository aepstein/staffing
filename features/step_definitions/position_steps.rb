Given /^(?:an )authorization scenario of a position to which I have an? (admin|staff|plain) relationship$/ do |tense, relationship|
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @position = create( :position )
end

Given /^I have a (current|past|future|recent|pending) (authority|authority_ro|member) relationship to the position$/ do |tense, relationship|
  @position.authority.committee = create(:committee)
  @position.authority.save!
  position = case relationship
  when 'authority'
    create(:enrollment, committee: @position.authority.committee, votes: 1).position
  when 'authority_ro'
    create(:enrollment, committee: @position.authority.committee, votes: 0).position
  else
    @position
  end
  period = case tense
  when 'recent', 'pending'
    create(:current_period, schedule: position.schedule)
  else
    create("#{tense}_period".to_sym, schedule: position.schedule)
  end
  @authority_membership = case tense
  when 'recent'
    create(:membership, user: @current_user, position: position, period: period, ends_at: ( Time.zone.today - 1.day ))
  when 'pending'
    create(:membership, user: @current_user, position: position, period: period, starts_at: ( Time.zone.today + 1.day ))
  else
    create(:membership, user: @current_user, position: position, period: period)
  end
end

Then /^I may( not)? see the position$/ do |negate|
  visit(position_url(@position))
  step %{I should#{negate} be authorized}
  visit(positions_url)
  if negate.blank?
    page.should have_selector( "#position-#{@position.id}" )
  else
    page.should have_no_selector( "#position-#{@position.id}" )
  end
end

Then /^I may( not)? create positions$/ do |negate|
  Capybara.current_session.driver.submit :post, positions_url, {}
  step %{I should#{negate} be authorized}
  visit(new_position_url)
  step %{I should#{negate} be authorized}
  visit(positions_url)
  if negate.blank?
    page.should have_text('New position')
  else
    page.should have_no_text('New position')
  end
end

Then /^I may( not)? update the position$/ do |negate|
  Capybara.current_session.driver.submit :put, position_url(@position), {}
  step %{I should#{negate} be authorized}
  visit(edit_position_url(@position))
  step %{I should#{negate} be authorized}
  visit(positions_url)
  if negate.blank?
    within("#position-#{@position.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the position$/ do |negate|
  visit(positions_url)
  if negate.blank?
    within("#position-#{@position.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, position_url(@position), {}
  step %{I should#{negate} be authorized}
end

When /^I create a position$/ do
  create :authority, name: 'Supreme'
  create :authority, name: 'Inferior'
  create :schedule, name: 'Annual'
  create :schedule, name: 'Semester'
  create :quiz, name: "Generic"
  create :quiz, name: "Specialized"
  create :committee, name: "Cool Committee"
  visit(new_position_path)
  select "Supreme", from: "Authority"
  select "Generic", from: "Quiz"
  select "Annual", from: "Schedule"
  within_fieldset("Renewable?") { choose "Yes" }
  within_fieldset("Notifiable?") { choose "Yes" }
  within_fieldset("Designable?") { choose "Yes" }
  within_fieldset("Active?") { choose "Yes" }
  fill_in "Slots", with: "1"
  within_fieldset("Statuses") { check "undergrad" }
  fill_in "Name", with: "Popular Committee Member"
  fill_in "Join message", with: "Welcome to *committee*."
  fill_in "Leave message", with: "You were *dropped* from the committee."
  fill_in "Reject message", with: "There were *no* slots."
  click_link "add enrollment"
  fill_in "Committee", with: "Cool Committee"
  fill_in "Title", with: "Voting Member"
  fill_in "Votes", with: "1"
  within_fieldset("Requestable?") { choose 'Yes' }
  within_fieldset("Membership notices?") { choose 'Yes' }
  within_fieldset("Manager?") { choose 'Yes' }
  click_button 'Create'
  @position = Position.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new position$/ do
  within( "#flash_notice" ) { page.should have_text( "Position was successfully created." ) }
  within( "#position-#{@position.id}" ) do
    page.should have_text "Authority: Supreme"
    page.should have_text "Quiz: Generic"
    page.should have_text "Schedule: Annual"
    page.should have_text "Renewable? Yes"
    page.should have_text "Notifiable? Yes"
    page.should have_text "Designable? Yes"
    page.should have_text "Active? Yes"
    page.should have_text "Slots: 1"
    page.should have_text "undergrad"
    page.should have_text "Name: Popular Committee Member"
    page.should have_text "Welcome to committee."
    page.should have_text "You were dropped from the committee."
    page.should have_text "There were no slots."
    page.should have_no_text "No enrollments."
    step %{I should see the following enrollments:}, table(%{
      | Cool Committee | Voting Member | 1 |
    })
    enrollment = @position.enrollments.first
    within("tr#enrollment-#{enrollment.id}") do
      within("td:nth-of-type(4)") { page.should have_text "Yes" }
      within("td:nth-of-type(5)") { page.should have_text "Yes" }
      within("td:nth-of-type(6)") { page.should have_text "Yes" }
    end
  end
end

When /^I update the position$/ do
  visit(edit_position_path(@position))
  select "Inferior", from: "Authority"
  select "Specialized", from: "Quiz"
  select "Semester", from: "Schedule"
  within_fieldset("Renewable?") { choose "No" }
  within_fieldset("Notifiable?") { choose "No" }
  within_fieldset("Designable?") { choose "No" }
  within_fieldset("Active?") { choose "No" }
  fill_in "Slots", with: "2"
  within_fieldset("Statuses") { uncheck "undergrad" }
  fill_in "Name", with: "Normal Committee Member"
  fill_in "Join message", with: "Welcome!"
  fill_in "Leave message", with: "Goodbye!"
  fill_in "Reject message", with: "No more room!"
  click_link "remove enrollment"
  click_button 'Update'
end

Then /^I should see the edited position$/ do
  within('#flash_notice') { page.should have_text( "Position was successfully updated." ) }
  within("#position-#{@position.id}") do
    page.should have_text "Authority: Inferior"
    page.should have_text "Quiz: Specialized"
    page.should have_text "Schedule: Semester"
    page.should have_text "Renewable? No"
    page.should have_text "Notifiable? No"
    page.should have_text "Designable? No"
    page.should have_text "Active? No"
    page.should have_text "Slots: 2"
    page.should have_no_text "undergrad"
    page.should have_text "Name: Normal Committee Member"
    page.should have_text "Welcome!"
    page.should have_text "Goodbye!"
    page.should have_text "No more room!"
    page.should have_text "No enrollments."
  end
end

Given /^there are (\d+) positions$/ do |quantity|
  @positions = quantity.to_i.downto(1).
    map { |i| create :position, name: "Position #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) position$/ do |text, position|
  visit(positions_url)
  within("table > tbody > tr:nth-child(#{position.to_i})") do
    click_link "#{text}"
  end
  within("#flash_notice") { page.should have_text("Position was successfully destroyed.") }
end

Then /^I should see the following positions:$/ do |table|
  table.diff! tableish( 'table#positions > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for positions with name "([^"]+)"$/ do |needle|
  visit(positions_url)
  fill_in "Name", with: needle
  click_button "Search"
end

