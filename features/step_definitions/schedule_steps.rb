Given /^(?:an )authorization scenario of a schedule to which I have an? (admin|staff|plain) relationship$/ do |role|
  step %{I log in as the #{role} user}
  @schedule = create( :schedule )
end

Then /^I may( not)? see the schedule$/ do |negate|
  visit(schedule_url(@schedule))
  step %{I should#{negate} be authorized}
  visit(schedules_url)
  if negate.blank?
    expect( page ).to have_selector( "#schedule-#{@schedule.id}" )
  else
    expect( page ).to have_no_selector( "#schedule-#{@schedule.id}" )
  end
end

Then /^I may( not)? create schedules$/ do |negate|
  Capybara.current_session.driver.submit :post, schedules_url,
    { "schedule" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_schedule_url)
  step %{I should#{negate} be authorized}
  visit(schedules_url)
  if negate.blank?
    expect( page ).to have_text('New schedule')
  else
    expect( page ).to have_no_text('New schedule')
  end
end

Then /^I may( not)? update the schedule$/ do |negate|
  Capybara.current_session.driver.submit :put, schedule_url(@schedule),
    { "schedule" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_schedule_url(@schedule))
  step %{I should#{negate} be authorized}
  visit(schedules_url)
  if negate.blank?
    within("#schedule-#{@schedule.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the schedule$/ do |negate|
  visit(schedules_url)
  if negate.blank?
    within("#schedule-#{@schedule.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, schedule_url(@schedule), {}
  step %{I should#{negate} be authorized}
end

When /^I create a schedule$/ do
  visit(new_schedule_path)
  fill_in "Name", with: "Annual"
  click_link "Add Period"
  fill_in "Starts at", with: Date.new(2010,1,1).to_s(:db)
  fill_in "Ends at", with: Date.new(2010,12,31).to_s(:db)
  click_button 'Create'
  @schedule = Schedule.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new schedule$/ do
  within( ".alert" ) { expect( page ).to have_text( "Schedule created." ) }
  within( "#schedule-#{@schedule.id}" ) do
    expect( page ).to have_text "Name: Annual"
    expect( page ).to have_no_text "No periods."
    step %{I should see the following periods:}, table(%{
      | 01/01/2010 | 12/31/2010 |
    })
  end
end

When /^I update the schedule$/ do
  visit(edit_schedule_path(@schedule))
  fill_in "Name", with: "Empty"
  click_link "Remove Period"
  click_button 'Update'
end

Then /^I should see the edited schedule$/ do
  within('.alert') { expect( page ).to have_text( "Schedule updated." ) }
  within("#schedule-#{@schedule.id}") do
    expect( page ).to have_text "Name: Empty"
    expect( page ).to have_text "No periods."
  end
end

Given /^there are (\d+) schedules$/ do |quantity|
  @schedules = quantity.to_i.downto(1).
    map { |i| create :schedule, name: "Schedule #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) schedule$/ do |text, schedule|
  visit(schedules_url)
  within("table > tbody > tr:nth-child(#{schedule.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Schedule destroyed.") }
end

Then /^I should see the following schedules:$/ do |table|
  table.diff! tableish( 'table#schedules > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for schedules with name "([^"]+)"$/ do |needle|
  visit(schedules_url)
  fill_in "Name", with: needle
  click_button "Search"
end

