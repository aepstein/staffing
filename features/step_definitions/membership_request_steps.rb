Given /^(?:an )authorization scenario of an? (current|expired) membership_request to which I have a(?: (current|recent|pending|future))? (admin|staff|authority|authority_ro|requestor|plain) relationship$/ do |membership_request_tense, relation_tense, relationship|
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  user = case relationship
  when 'requestor'
    @current_user
  else
    create(:user)
  end
  @membership_request = case membership_request_tense
  when 'current'
    create(:membership_request, user: user)
  else
    create("#{membership_request_tense}_membership_request".to_sym, user: user)
  end
  @committee = @membership_request.committee
  @position = @committee.positions.first
  if %w( authority authority_ro ).include?( relationship )
    step %{I have a #{relation_tense} #{relationship} relationship to the position}
  end
end

Then /^I may( not)? create membership_requests for the committee$/ do |negate|
  visit(new_committee_membership_request_url(@committee))
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit :post, committee_membership_requests_url(@committee), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? update the membership_request$/ do |negate|
  Capybara.current_session.driver.submit :put, membership_request_url(@membership_request), {}
  step %{I should#{negate} be authorized}
  visit(edit_membership_request_url(@membership_request))
  step %{I should#{negate} be authorized}
  visit(committee_membership_requests_url(@committee))
  if negate.blank?
    within("#membership-request-#{@membership_request.id}") { page.should have_text('Edit') }
  else
    if page.has_selector?("#membership-request-#{@membership_request.id}")
      within("#membership-request-#{@membership_request.id}") { page.should have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? destroy the membership_request$/ do |negate|
  visit(committee_membership_requests_url(@committee))
  if negate.blank?
    within("#membership-request-#{@membership_request.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, membership_request_url(@membership_request), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? see the membership_request$/ do |negate|
  visit(membership_request_url(@membership_request))
  step %{I should#{negate} be authorized}
  visit(committee_membership_requests_url(@committee))
  if negate.blank?
    page.should have_selector( "#membership-request-#{@membership_request.id}" )
  else
    page.should have_no_selector( "#membership-request-#{@membership_request.id}" )
  end
end

Then /^I may( not)? reject the membership_request$/ do |negate|
  visit(committee_membership_requests_url(@committee))
  if negate.blank?
    within("#membership-request-#{@membership_request.id}") { page.should have_text('Reject') }
  else
    if page.has_selector?("#membership-request-#{@membership_request.id}")
      within("#membership-request-#{@membership_request.id}") { page.should have_no_text('Reject') }
    end
  end
  visit(reject_membership_request_url(@membership_request))
  step %{I should#{negate} be authorized}
  Capybara.current_session.driver.submit :put, reject_membership_request_url(@membership_request), {}
  step %{I should#{negate} be authorized}
end

When /^I create a membership_request$/ do |membership_request_tense, relation_tense, relation|
  step %{I log in as the plain user}
  @committee = create(:committee, designable: true)
  create(:enrollment, committee: @committee, committee: create(:committee, name: 'Important Committee'))
  @past_period = create(:past_period, schedule: @committee.schedule)
  @current_period = create(:period, schedule: @committee.schedule)
  @future_period = create(:future_period, schedule: @committee.schedule)
  @period = case membership_request_tense
  when 'past'
    @past_period
  when 'future'
    @future_period
  else
    @current_period
  end
  @starts_at = case membership_request_tense
  when 'pending'
    Time.zone.today + 1.day
  else
    @period.starts_at
  end
  @ends_at = case membership_request_tense
  when 'recent'
    Time.zone.today - 1.day
  else
    @period.ends_at
  end
  @candidate = create(:user)
  @designee = create(:user)
  if relation == 'authority'
    step %{I have a #{relation_tense} #{relation} relationship to the committee}
  end
  visit new_committee_membership_request_url(@committee)
  fill_in 'User', with: @candidate.name(:net_id)
  select @period.to_s, from: "Period"
  fill_in 'Starts at', with: @starts_at.to_s(:rfc822)
  fill_in 'Ends at', with: @ends_at.to_s(:rfc822)
  fill_in "Designee for Important Committee", with: @designee.name(:net_id)
  click_button 'Create'
end

Then /^I should( not)? see the modifier error message$/ do |negate|
  if negate.blank?
    within(".error_messages") { page.should have_text "must have authority to modify the committee between" }
  else
    @membership_request = MembershipRequest.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
    within('#flash_notice') { page.should have_text('Request was successfully created.') }
  end
end

Then /^I should see the new membership_request$/ do
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text("Committee: #{@committee.name}")
    page.should have_text("Period: #{@period.to_s}")
    page.should have_text("User: #{@candidate.name(:net_id)}")
    page.should have_text("Starts at: #{@starts_at.to_formatted_s(:us_ordinal)}")
    page.should have_text("Ends at: #{@ends_at.to_formatted_s(:us_ordinal)}")
    page.should have_text("Designee for Important Committee: #{@designee.name(:net_id)}")
  end
end

When /^I update the membership_request$/ do
  visit edit_membership_request_url(@membership_request)
  fill_in 'User', with: @designee.name(:net_id)
  @starts_at += 1.day
  @ends_at -= 1.day
  fill_in 'Starts at', with: @starts_at.to_s(:rfc822)
  fill_in 'Ends at', with: @ends_at.to_s(:rfc822)
  fill_in 'Designee for Important Committee', with: @candidate.name(:net_id)
  click_button 'Update'
end

Then /^I should see the edited membership_request$/ do
  within('#flash_notice') { page.should have_text("Request was successfully updated.") }
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text("User: #{@designee.name(:net_id)}")
    page.should have_text("Starts at: #{@starts_at.to_formatted_s(:us_ordinal)}")
    page.should have_text("Ends at: #{@ends_at.to_formatted_s(:us_ordinal)}")
    page.should have_text("Designee for Important Committee: #{@candidate.name(:net_id)}")
  end
end

Given /^I have a referred membership_request as (vicechair|staff)$/ do |relationship|
  role = case relationship
  when 'staff'
    'staff'
  else
    'plain'
  end
  committee_relationship = case relationship
  when 'staff'
    'nonmembership_request'
  else
    relationship
  end
  step %{I log in as the #{role} user}
  step %{I have a current #{committee_relationship} relationship to the committee}
  @membership_request = create( :referred_membership_request, committee: @committee )
  create(:attachment, attachable: @membership_request, description: "Sample employee ids")
end

When /^I update the referred membership_request$/ do
  visit(edit_membership_request_path(@membership_request))
  fill_in "Name", with: "Referred membership_request"
  fill_in "Description", with: "This is different"
  fill_in "Content", with: "Whereas and resolved"
  click_link "remove attachment"
  click_button "Update"
end

Then /^I should see the updated referred membership_request$/ do
  within('#flash_notice') { page.should have_text("Request was successfully updated.") }
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text("Name: Referred membership_request")
    page.should have_text("This is different")
    page.should have_text("Whereas and resolved")
    page.should have_no_text("Sample employee ids")
  end
end

Given /^there are (\d+) membership_requests for a committee by (end|start|last|first)$/ do |quantity, column|
  @period = create(:period, starts_at: '2011-01-01', ends_at: '2011-12-31')
  @committee = create(:committee, slots: quantity.to_i, minimum_slots: 0,
    schedule: @period.schedule)
  @membership_requests = quantity.to_i.downto(1).map do |i|
    case column
    when 'last'
      create :membership_request, committee: @committee, user: create( :user, last_name: "Doe1000#{i}" )
    when 'first'
      create :membership_request, committee: @committee, user: create( :user, first_name: "John1000#{i}" )
    when 'start'
      create :membership_request, committee: @committee, starts_at: ( @period.starts_at + (quantity.to_i - i).days )
    when 'end'
      create :membership_request, committee: @committee, ends_at: ( @period.ends_at - i.days )
    end
  end
end

Given /^there are (\d+) membership_requests with a common (committee|authority|user|committee)$/ do |quantity, common|
  @common = case common
  when 'committee'
    create(:committee, slots: quantity.to_i, minimum_slots: 0)
  else
    create(common.to_sym)
  end
  @membership_requests = quantity.to_i.times.inject([]) do |memo|
    memo << case common
    when 'committee'
      create(:membership_request, committee: @common)
    when 'authority'
      create(:membership_request, committee: create(:committee, authority: @common))
    when 'user'
      create(:membership_request, user: @common)
    when 'committee'
      create(:membership_request, committee: create(:enrollment, committee: @common).committee)
    end
  end
end

When /^I search for the (committee|authority|user|committee) of the (\d+)(?:st|nd|rd|th) membership_request$/ do |field, committee|
  visit polymorphic_url( [ @common, :membership_requests ] )
  pos = ( committee.to_i - 1 )
  case field
  when 'committee'
    fill_in 'Committee', with: @membership_requests[pos].committee.name
  when 'authority'
    fill_in 'Authority', with: @membership_requests[pos].committee.authority.name
  when 'user'
    fill_in 'User', with: @membership_requests[pos].user.net_id
  when 'committee'
    fill_in 'Committee',
      with: create(:enrollment, committee: @membership_requests[pos].committee).committee.name
  end
end

Then /^I should not see the search field for an? (committee|authority|user|committee)$/ do |field|
  page.should_not have_field field.titleize
end

Then /^I should only find the (\d+)(?:st|nd|rd|th) membership_request$/ do |committee|
  click_button "Search"
  pos = ( committee.to_i - 1 )
  needle = @membership_requests[pos].id
  within("#membership-requests") do
    ( @membership_requests.map(&:id) - [ needle ] ).each do |id|
      page.should_not have_selector "#membership-request-#{id}"
    end
    page.should have_selector "#membership-request-#{needle}"
  end
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) membership_request for the committee$/ do |text, membership_request|
  visit(committee_membership_requests_path(@committee))
  within("table > tbody > tr:nth-child(#{membership_request.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following membership_requests for the committee:$/ do |table|
  visit(committee_membership_requests_path(@committee))
  table.diff! tableish( 'table#membership-requests > tbody > tr', 'td' )
end

When /^I decline the membership_request$/ do
  visit decline_membership_request_url(@membership_request)
  fill_in "Comment", with: "No *membership_request* for you!"
  click_button "Decline Renewal"
end

Then /^I should see the membership_request declined$/ do
  @membership_request.reload
  within("#flash_notice") { page.should have_text( "MembershipRequest renewal was successfully declined." ) }
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text "Renewal declined at: #{@membership_request.declined_at.to_s(:long_ordinal)}"
    page.should have_text "Renewal declined by: #{@current_user.name(:net_id)}"
    page.should have_text "No membership_request for you!"
  end
end

When /^the (join|leave) notice has been sent$/ do |notice|
  @membership_request.send "send_#{notice}_notice!"
end

Then /^I should see the (join|leave) notice is sent$/ do |notice|
  visit membership_request_url @membership_request
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text( "#{notice.titleize} notice at: " +
      @membership_request.send("#{notice}_notice_at").to_formatted_s(:long_ordinal) )
  end
end

Given /^the membership_request is( not)? renewable$/ do |unrenewable|
  if unrenewable.blank?
    @membership_request.committee.update_column :renewable, true
  else
    @membership_request.committee.update_column :renewable, false
  end
  @original_renewal_checkpoint = @membership_request.user.renewal_checkpoint - 2.weeks
  @membership_request.user.update_column :renewal_checkpoint, @original_renewal_checkpoint
end

When /^I fill in (a|no) renewal for the membership_request$/ do |v|
  visit renew_user_membership_requests_url( @membership_request.user )
  within("#membership-request-#{@membership_request.id}") do
    fill_in "#{@membership_request.committee}",
      with: ( v == 'a' ? ( @membership_request.ends_at + 1.year ).to_formatted_s(:rfc822) : '' )
  end
end

When /^I submit renewals with renotification (en|dis)abled$/ do |renotify|
  select( ( renotify == 'en' ? "Yes" : "No" ), from: "Notify again?" )
  click_button 'Update renewals'
end

Then /^the membership_request should have (a|no) renewal$/ do |renotify|
  @membership_request.reload
  @membership_request.renew_until.should case renotify
  when 'a'
    eql @membership_request.ends_at + 1.year
  when 'no'
    be_nil
  end
end

Then /^I should see renewals confirmed with renotification (en|dis)abled$/ do |renotify|
  within("#flash_notice") { page.should have_text "Renewal preferences successfully updated." }
  @membership_request.user.reload
  if renotify == 'en'
    @membership_request.user.renewal_checkpoint.should be_within(1.second).of(@original_renewal_checkpoint)
  else
    @membership_request.user.renewal_checkpoint.should_not be_within(1.week).of(@original_renewal_checkpoint)
  end
end

Then /^I may( not)? renew the membership_request$/ do |negate|
  visit renew_user_membership_requests_url @membership_request.user
  if negate.blank?
    page.should have_selector "#membership-request-#{@membership_request.id}"
  else
    page.should have_no_selector "#membership-request-#{@membership_request.id}"
  end
end

