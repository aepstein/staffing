Given /^(?:an )authorization scenario of a meeting template to which I have an? (admin|staff|plain) relationship$/ do |role|
  step %{I log in as the #{role} user}
  @meeting_template = create( :meeting_template )
end

Then /^I may( not)? see the meeting template$/ do |negate|
  visit(meeting_template_url(@meeting_template))
  step %{I should#{negate} be authorized}
  visit(meeting_templates_url)
  if negate.blank?
    expect( page ).to have_selector( "#meeting-template-#{@meeting_template.id}" )
  else
    expect( page ).to have_no_selector( "#meeting-template-#{@meeting_template.id}" )
  end
end

Then /^I may( not)? create meeting templates$/ do |negate|
  Capybara.current_session.driver.submit :post, meeting_templates_url,
    { "meeting_template" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_meeting_template_url)
  step %{I should#{negate} be authorized}
  visit(meeting_templates_url)
  if negate.blank?
    expect( page ).to have_text('New meeting template')
  else
    expect( page ).to have_no_text('New meeting template')
  end
end

Then /^I may( not)? update the meeting template$/ do |negate|
  Capybara.current_session.driver.submit :put,
    meeting_template_url(@meeting_template),
    { "meeting_template" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_meeting_template_url(@meeting_template))
  step %{I should#{negate} be authorized}
  visit(meeting_templates_url)
  if negate.blank?
    within("#meeting-template-#{@meeting_template.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the meeting template$/ do |negate|
  visit(meeting_templates_url)
  if negate.blank?
    within("#meeting-template-#{@meeting_template.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, meeting_template_url(@meeting_template), {}
  step %{I should#{negate} be authorized}
end

When /^I create a meeting template$/ do
  visit(new_meeting_template_path)
  fill_in "Meeting template name", with: "Annual"
  click_link "Add Meeting Section Template"
  within_fieldset "New Meeting Section Template" do
    fill_in "Name", with: "Call to Order"
    click_link "Add Meeting Item Template"
    within_fieldset "New Meeting Item Template" do
      fill_in "Name", with: "Roll Call"
    end
  end
  click_button 'Create'
  @meeting_template = MeetingTemplate.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new meeting template$/ do
  within( ".alert" ) { expect( page ).to have_text( "Meeting template created." ) }
  within( "#meeting-template-#{@meeting_template.id}" ) do
    expect( page ).to have_text "Meeting template name: Annual"
    expect( page ).to have_no_text "No periods."
    expect( page ).to have_text "Call to Order"
    expect( page ).to have_text "Roll Call"
  end
end

When /^I update the meeting template$/ do
  visit(edit_meeting_template_path(@meeting_template))
  fill_in "Meeting template name", with: "Empty"
  click_link "Remove Meeting Section Template"
  click_button 'Update'
end

Then /^I should see the edited meeting template$/ do
  within('.alert') { expect( page ).to have_text( "Meeting template updated." ) }
  within("#meeting-template-#{@meeting_template.id}") do
    expect( page ).to have_text "Meeting template name: Empty"
    expect( page ).to have_text "No meeting section templates."
  end
end

Given /^there are (\d+) meeting templates$/ do |quantity|
  @meeting_templates = quantity.to_i.downto(1).
    map { |i| create :meeting_template, name: "Meeting Template #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) meeting template$/ do |text, meeting_template|
  visit(meeting_templates_url)
  within("table > tbody > tr:nth-child(#{meeting_template.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Meeting template destroyed.") }
end

Then /^I should see the following meeting templates:$/ do |table|
  table.diff! tableish( 'table#meeting-templates > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for meeting templates with name "([^"]+)"$/ do |needle|
  visit(meeting_templates_url)
  fill_in "Name", with: needle
  click_button "Search"
end

