When /^I create a minute motion for the meeting with (past|current|default) period$/ do |period|
  @current = if @meeting.period.ends_at < Time.zone.today
    @past = @meeting.period
    create(:period, schedule: @meeting.committee.schedule)
  else
    @meeting.period
  end
  visit new_meeting_motion_path( @meeting )
  if period == 'default'
  elsif period == 'current'
    select @current.to_s, from: 'Period'
  else
    select @past.to_s, from: 'Period'
  end
  within_fieldset("Meeting Segments") do
    within_fieldset(@meeting.meeting_items.first.to_s) do
      fill_in "Content", with: "Somebody talked about *something*."
    end
  end
  click_button "Create Motion"
end

Then /^I should see the new minute motion with (past|current) period$/ do |period|
  within(".alert") { page.should have_text 'Motion created.' }
  if period == 'current'
    page.should have_text "Period: #{@current.to_s}"
  else
    page.should have_text "Period: #{@past.to_s}"
  end
  @motion = Motion.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  page.should have_text "Somebody talked about something."
end

When /^I update the minute motion$/ do
  visit edit_motion_path( @motion )
  click_link "Remove Meeting Segment"
  click_link "Add Motion Meeting Segment"
  within_fieldset("New Meeting Segment") do
    fill_in "Description", with: "Unscheduled Topic"
    fill_in "Content", with: "Somebody *should* have called for orders of the day."
  end
  click_button "Update Motion"
end

Then /^I should see the updated minute motion$/ do
  within(".alert") { page.should have_text "Motion updated." }
end

Then /^I may( not)? create minute motions for the meeting$/ do |negate|
  visit meeting_url( @meeting )
  if negate.blank?
    page.should have_text "Add Minutes"
  else
    page.should have_no_text "Add Minutes"
  end
  visit new_meeting_motion_path( @meeting )
  step %{I should#{negate} be authorized}
end

