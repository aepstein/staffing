Given /^(?:an )authorization scenario of a position to which I have an? (?:(current|past|future|recent|pending) )?(admin|staff|plain|authority|authority_ro|member) relationship$/ do |tense, relationship|
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @position = create( :position )
  case relationship
  when 'admin', 'staff', 'plain'
  else
    step %{I have a #{tense} #{relationship} relationship to the position}
  end
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
    expect( page ).to have_selector( "#position-#{@position.id}" )
  else
    expect( page ).to have_no_selector( "#position-#{@position.id}" )
  end
end

Then /^I may( not)? create positions$/ do |negate|
  Capybara.current_session.driver.submit :post, positions_url,
    { "position" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_position_url)
  step %{I should#{negate} be authorized}
  visit(positions_url)
  if negate.blank?
    expect( page ).to have_text('New position')
  else
    expect( page ).to have_no_text('New position')
  end
end

Then /^I may( not)? update the position$/ do |negate|
  Capybara.current_session.driver.submit :put, position_url(@position),
    { "position" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_position_url(@position))
  step %{I should#{negate} be authorized}
  visit(positions_url)
  if negate.blank?
    within("#position-#{@position.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the position$/ do |negate|
  visit(positions_url)
  if negate.blank?
    within("#position-#{@position.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
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
  within_control_group("Renewable?") { choose "Yes" }
  within_control_group("Notifiable?") { choose "Yes" }
  within_control_group("Designable?") { choose "Yes" }
  within_control_group("Active?") { choose "Yes" }
  fill_in "Slots", with: "1"
  fill_in "Minimum slots", with: "1"
  within_control_group("Statuses") { check "undergrad" }
  fill_in "Name", with: "Popular Committee Member"
  fill_in "Appoint message", with: "You will soon be in *position*."
  fill_in "Join message", with: "Welcome to *committee*."
  fill_in "Leave message", with: "You were *dropped* from the committee."
  fill_in "Reject message", with: "There were *no* slots."
  click_link "Add Enrollment"
  fill_in "Committee", with: "Cool Committee"
  fill_in "Title", with: "Voting Member"
  fill_in "Votes", with: "1"
  within_control_group("Requestable?") { choose 'Yes' }
  within_control_group("Roles") do
    check 'vicechair'
    check 'monitor'
  end
  click_button 'Create'
  @position = Position.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new position$/ do
  within( ".alert" ) { expect( page ).to have_text( "Position created." ) }
  within( "#position-#{@position.id}" ) do
    expect( page ).to have_text "Authority: Supreme"
    expect( page ).to have_text "Quiz: Generic"
    expect( page ).to have_text "Schedule: Annual"
    expect( page ).to have_text "Renewable? Yes"
    expect( page ).to have_text "Notifiable? Yes"
    expect( page ).to have_text "Designable? Yes"
    expect( page ).to have_text "Active? Yes"
    expect( page ).to have_text "Slots: 1"
    expect( page ).to have_text "Minimum slots: 1"
    expect( page ).to have_text "undergrad"
    expect( page ).to have_text "Name: Popular Committee Member"
    expect( page ).to have_text "You will soon be in position."
    expect( page ).to have_text "Welcome to committee."
    expect( page ).to have_text "You were dropped from the committee."
    expect( page ).to have_text "There were no slots."
    expect( page ).to have_no_text "No enrollments."
    step %{I should see the following enrollments:}, table(%{
      | Cool Committee | Voting Member | 1 |
    })
    enrollment = @position.enrollments.first
    within("tr#enrollment-#{enrollment.id}") do
      within("td:nth-of-type(4)") { expect( page ).to have_text "Yes" }
      within("td:nth-of-type(5)") { expect( page ).to have_text "vicechair, monitor" }
    end
  end
end

When /^I update the position$/ do
  visit(edit_position_path(@position))
  select "Inferior", from: "Authority"
  select "Specialized", from: "Quiz"
  select "Semester", from: "Schedule"
  within_control_group("Renewable?") { choose "No" }
  within_control_group("Notifiable?") { choose "No" }
  within_control_group("Designable?") { choose "No" }
  within_control_group("Active?") { choose "No" }
  fill_in "Slots", with: "2"
  fill_in "Minimum slots", with: "2"
  within_control_group("Statuses") { uncheck "undergrad" }
  fill_in "Name", with: "Normal Committee Member"
  fill_in "Appoint message", with: "Pre-welcome!"
  fill_in "Join message", with: "Welcome!"
  fill_in "Leave message", with: "Goodbye!"
  fill_in "Reject message", with: "No more room!"
  click_link "Remove Enrollment"
  click_button 'Update'
end

Then /^I should see the edited position$/ do
  within('.alert') { expect( page ).to have_text( "Position updated." ) }
  within("#position-#{@position.id}") do
    expect( page ).to have_text "Authority: Inferior"
    expect( page ).to have_text "Quiz: Specialized"
    expect( page ).to have_text "Schedule: Semester"
    expect( page ).to have_text "Renewable? No"
    expect( page ).to have_text "Notifiable? No"
    expect( page ).to have_text "Designable? No"
    expect( page ).to have_text "Active? No"
    expect( page ).to have_text "Slots: 2"
    expect( page ).to have_text "Minimum slots: 2"
    expect( page ).to have_no_text "undergrad"
    expect( page ).to have_text "Name: Normal Committee Member"
    expect( page ).to have_text "Pre-welcome!"
    expect( page ).to have_text "Welcome!"
    expect( page ).to have_text "Goodbye!"
    expect( page ).to have_text "No more room!"
    expect( page ).to have_text "No enrollments."
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
  within(".alert") { expect( page ).to have_text("Position destroyed.") }
end

Then /^I should see the following positions:$/ do |table|
  table.diff! tableish( 'table#positions > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for positions with name "([^"]+)"$/ do |needle|
  visit(positions_url)
  fill_in "Name", with: needle
  click_button "Search"
end

