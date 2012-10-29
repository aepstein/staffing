Given /^(?:an )authorization scenario of an? (current|recent|pending|future|past) (un)?published meeting of a committee to which I have a (current|recent|pending) (admin|staff|chair|vicechair|voter|nonvoter|plain) relationship$/ do |meeting_tense, unpub, member_tense, relationship|
  Motion.delete_all
  committee_relationship = case relationship
  when 'admin', 'staff', 'plain'
    'nonmember'
  else
    relationship
  end
  role = case relationship
  when 'admin'
    'admin'
  when 'staff'
    'staff'
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  step %{I have a #{member_tense} #{committee_relationship} relationship to the committee}
  case meeting_tense
  when 'recent', 'pending', 'current'
    @period = create( :current_period, schedule: @committee.schedule )
    @meeting = create "#{meeting_tense}_meeting".to_sym, committee: @committee,
      period: @period, published: unpub.blank?
  else
    @period = create( "#{meeting_tense}_period", schedule: @committee.schedule )
    @meeting = create :meeting, committee: @committee,
      period: @period, published: unpub.blank?
  end
end

Then /^I may( not)? see the meeting$/ do |negate|
  visit(meeting_url(@meeting))
  step %{I should#{negate} be authorized}
  visit(committee_meetings_url(@meeting))
  if negate.blank?
    page.should have_selector( "#meeting-#{@meeting.id}" )
  else
    page.should have_no_selector( "#meeting-#{@meeting.id}" )
  end
end

Then /^I may( not)? create meetings$/ do |negate|
  Capybara.current_session.driver.submit :post, committee_meetings_url(@committee),
    { "meeting" => { "period_id" => "#{@period.id}" } }
  step %{I should#{negate} be authorized}
  if @period.current?
    visit(new_committee_meeting_url(@committee))
    step %{I should#{negate} be authorized}
  end
  visit(committee_meetings_url(@committee))
  if negate.blank?
    page.should have_text('New meeting')
  else
    page.should have_no_text('New meeting')
  end
end

Then /^I may( not)? update the meeting$/ do |negate|
  Capybara.current_session.driver.submit :put, meeting_url(@meeting), {}
  step %{I should#{negate} be authorized}
  visit(edit_meeting_url(@meeting))
  step %{I should#{negate} be authorized}
  visit(committee_meetings_url(@committee))
  if negate.blank?
    within("#meeting-#{@meeting.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the meeting$/ do |negate|
  visit(committee_meetings_url(@committee))
  if negate.blank?
    within("#meeting-#{@meeting.id}") { page.should have_text('Destroy') }
  elsif page.has_selector?("#meeting-#{@meeting.id}")
    within("#meeting-#{@meeting.id}") { page.should have_no_text('Destroy') }
  end
  Capybara.current_session.driver.submit :delete, meeting_url(@meeting), {}
  step %{I should#{negate} be authorized}
end

When /^I create a meeting as (staff|chair)$/ do |relationship|
  role = case relationship
  when 'staff'
    relationship
  else
    'plain'
  end
  committee_relationship = case relationship
  when 'staff'
    'nonmember'
  else
    relationship
  end
  step %{I log in as the #{role} user}
  step %{I have a current #{committee_relationship} relationship to the committee}
  @past_period = create(:past_period, schedule: @committee.schedule)
  @current_period = create(:current_period, schedule: @committee.schedule)
  visit(new_committee_meeting_path(@committee))
  if relationship == 'staff'
    select @current_period.to_s, from: "Period"
  end
  @start = Time.zone.now + 1.day
  @end = (Time.zone.now + 1.day) + 1.hour
  fill_in "Starts at", with: "#{@start.to_s :rfc822}"
  fill_in "Ends at", with: "#{@end.to_s :rfc822}"
  fill_in "Location", with: "Green Room"
  click_button 'Create'
  @meeting = Meeting.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new meeting$/ do
  within( "#flash_notice" ) { page.should have_text( "Meeting was successfully created." ) }
  within( "#meeting-#{@meeting.id}" ) do
    page.should have_text "Committee: #{@committee.name}"
    page.should have_text "Period: #{@current_period}"
    page.should have_text "Starts at: #{@start.to_s :long_ordinal}"
    page.should have_text "Ends at: #{@end.to_s :long_ordinal}"
    page.should have_text "Location: Green Room"
    page.should have_text "Audio? No"
    page.should have_text "Editable minutes? No"
    page.should have_text "Published minutes? No"
  end
end

When /^I update the meeting$/ do
  @start += 1.hour
  @end += 1.hour
  visit(edit_meeting_path(@meeting))
  fill_in "Starts at", with: "#{@start.to_s :rfc822}"
  fill_in "Ends at", with: "#{@end.to_s :rfc822}"
  fill_in "Location", with: "Red Room"
  attach_file "Audio", File.expand_path("spec/assets/audio.mp3")
  attach_file "Editable minutes", temporary_file("minutes.doc",20.bytes)
  attach_file "Published minutes", temporary_file("minutes.pdf",20.bytes)
  click_button 'Update'
end

Then /^I should see the edited meeting$/ do
  within('#flash_notice') { page.should have_text( "Meeting was successfully updated." ) }
  within("#meeting-#{@meeting.id}") do
    page.should have_text "Starts at: #{@start.to_s :long_ordinal}"
    page.should have_text "Ends at: #{@end.to_s :long_ordinal}"
    page.should have_text "Location: Red Room"
    page.should have_text "Audio? Yes"
    page.should have_text "Editable minutes? Yes"
    page.should have_text "Published minutes? Yes"
  end
end

Given /^there are (\d+) meetings$/ do |quantity|
  @committee = create(:committee)
  @meetings = []; i = 1
  while i < 5 do
    period = create( :period, starts_at: Date.new(2000+i,01,01),
      ends_at: Date.new(2000+i,12,31),
      schedule: @committee.schedule )
    @meetings << create( :meeting,
      starts_at: Time.zone.local(2000+i,01,01,9,0,0),
      period: period,
      committee: @committee )
    i += 1
  end
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) meeting$/ do |text, meeting|
  visit(committee_meetings_url(@committee))
  within("table > tbody > tr:nth-child(#{meeting.to_i})") do
    click_link "#{text}"
  end
  within("#flash_notice") { page.should have_text("Meeting was successfully destroyed.") }
end

Then /^I should see the following meetings:$/ do |table|
  table.diff! tableish( 'table#meetings > tbody > tr', 'td:nth-of-type(2)' )
end

When /^I search for meetings with period "([^"]+)"$/ do |needle|
  visit(committee_meetings_url(@committee))
  select needle, from: 'Period'
  click_button "Search"
end

