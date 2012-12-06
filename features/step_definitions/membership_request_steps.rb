Given /^(?:an )authorization scenario of an? (current|expired)(?: (rejected|active|closed))? membership_request to which I have a(?: (current|recent|pending|future))? (admin|staff|authority|authority_ro|requestor|plain) relationship$/ do |membership_request_tense, state, relation_tense, relationship|
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
  case state
  when 'rejected'
    @membership_request.rejected_by_user = create(:user, admin: true)
    @membership_request.rejected_by_authority = @position.authority
    @membership_request.rejection_comment = 'Reason for disapproval'
    @membership_request.reject!
  when 'closed'
    @membership_request.close!
  end
end

Then /^I may( not)? create membership_requests for the committee$/ do |negate|
  if negate.blank?
    visit(new_committee_membership_request_url(@committee))
    step %{I should be authorized}
    Capybara.current_session.driver.submit :post, committee_membership_requests_url(@committee), {}
    step %{I should be authorized}
  else
    visit(new_committee_membership_request_url(@committee))
    step %{I fill in basic fields for the membership_request}
    click_button 'Create'
    step %{I should see the creator error message}
  end
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

Then /^I may( not)? reactivate the membership_request$/ do |negate|
  visit(committee_membership_requests_url(@committee))
  if negate.blank?
    within("#membership-request-#{@membership_request.id}") { page.should have_text('Reactivate') }
  else
    if page.has_selector?("#membership-request-#{@membership_request.id}")
      within("#membership-request-#{@membership_request.id}") { page.should have_no_text('Reactivate') }
    end
  end
  Capybara.current_session.driver.submit :put, reactivate_membership_request_url(@membership_request), {}
  step %{I should#{negate} be authorized}
end

Given /^(?:an? )?(#{User::STATUSES.join '|'}|(?:every|any|no)(?:one|body)) may create membership_requests for the committee$/ do |status|
  @committee = create(:committee)
  @enrollment = case status
  when /^(every|any)/
    create :enrollment, committee: @committee, requestable: true
  when /^no/
    create :enrollment, committee: @committee, requestable: false
  else
    create :enrollment, committee: @committee, requestable: true, position: create( :position, statuses: [ status ] )
  end
  @quiz = @enrollment.position.quiz
end

When /^I fill in basic fields for the membership_request$/ do
  @starts ||= Time.zone.today
  @ends ||= @starts + 2.years
  fill_in 'Desired start date', with: @starts.to_s(:rfc822)
  fill_in 'Desired end date', with: @ends.to_s(:rfc822)
end

When /^I create a membership_request for the committee$/ do
  @questions = [ create( :quiz_question, position: 3, quiz: @quiz,
    question: create(:question, name: 'Favorite color',
      content: 'What is your favority color?', disposition: 'string')),
  create( :quiz_question, position: 2, quiz: @quiz,
    question: create(:question, name: 'Capital of Assyria',
      content: 'What is the capital of Assyria?')),
  create( :quiz_question, position: 1, quiz: @quiz,
    question: create(:question, name: 'Qualified',
      content: 'Are you qualified?', disposition: 'boolean')) ]
  visit new_committee_membership_request_url(@committee)
  step %{I fill in basic fields for the membership_request}
  # TODO: Assure order of questions is observed
  fill_in 'Favorite color', with: '*bl*ue'
  fill_in 'Capital of Assyria', with: '*Da*mascus'
  within_fieldset('Qualified?') { choose 'Yes' }
  click_button 'Create'
end

Then /^I should( not)? see the creator error message$/ do |negate|
  if negate.blank?
    within(".error_messages") { page.should have_text "may not request membership in the committee" }
  else
    @membership_request = MembershipRequest.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
    within('#flash_notice') { page.should have_text('Membership request was successfully created.') }
  end
end

Then /^I should see the new membership_request$/ do
  step %{I should not see the creator error message}
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text "Committee: #{@committee.name}"
    page.should have_text "User: #{@current_user.name(:net_id)}"
    page.should have_text "Desired start date: #{@starts.to_formatted_s(:long_ordinal)}"
    page.should have_text "Desired end date: #{@ends.to_formatted_s(:long_ordinal)}"
    within("ol#answers") do
      within("li:nth-of-type(3)") { page.should have_text "What is your favority color? blue" }
      within("li:nth-of-type(2)") { page.should have_text "Damascus" }
      within("li:nth-of-type(1)") { page.should have_text "Are you qualified? Yes" }
    end
  end
end

When /^I update the membership_request$/ do
  @questions[0].update_column :position, 1
  @questions[2].update_column :position, 3
  visit edit_membership_request_url(@membership_request)
  @starts += 1.day
  @ends -= 1.day
  step %{I fill in basic fields for the membership_request}
  # TODO: Assure order of questions is observed
  fill_in 'Favorite color', with: 'yellow'
  fill_in 'Capital of Assyria', with: 'Carthage'
  within_fieldset('Qualified?') { choose 'No' }
  click_button 'Update'
end

Then /^I should see the updated membership_request$/ do
  within('#flash_notice') { page.should have_text("Membership request was successfully updated.") }
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text "Desired start date: #{@starts.to_formatted_s(:long_ordinal)}"
    page.should have_text "Desired end date: #{@ends.to_formatted_s(:long_ordinal)}"
    within("ol#answers") do
      within("li:nth-of-type(1)") { page.should have_text "What is your favority color? yellow" }
      within("li:nth-of-type(2)") { page.should have_text "Carthage" }
      within("li:nth-of-type(3)") { page.should have_text "Are you qualified? No" }
    end
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

Given /^there are (\d+) membership_requests for a committee by (last|first)$/ do |quantity, column|
  @committee = create(:requestable_committee)
  @membership_requests = quantity.to_i.downto(1).map do |i|
    case column
    when 'last'
      create :membership_request, committee: @committee, user: create( :user, last_name: "Doe1000#{i}" )
    when 'first'
      create :membership_request, committee: @committee, user: create( :user, first_name: "John1000#{i}" )
    end
  end
end

Given /^there are (\d+) membership_requests with a common (committee|user)$/ do |quantity, common|
  @common = case common
  when 'committee'
    create(:requestable_committee)
  else
    create(common.to_sym)
  end
  @membership_requests = quantity.to_i.times.inject([]) do |memo|
    memo << case common
    when 'committee'
      create(:membership_request, committee: @common)
    when 'user'
      create(:membership_request, user: @common)
    end
  end
end

When /^I search for the (user|committee) of the (\d+)(?:st|nd|rd|th) membership_request$/ do |field, committee|
  visit polymorphic_url( [ @common, :membership_requests ] )
  pos = ( committee.to_i - 1 )
  case field
  when 'committee'
    fill_in 'Committee', with: @membership_requests[pos].committee.name
  when 'user'
    fill_in 'User', with: @membership_requests[pos].user.net_id
  end
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

Given /^the membership_request is rejected$/ do
  @membership_request.rejected_by_authority = @position.authority
  @membership_request.rejected_by_user = create(:user, admin: true)
  @membership_request.rejection_comment = "Membership *denied*."
  @membership_request.reject!
end

When /^I reject the membership_request$/ do
  visit reject_membership_request_url(@membership_request)
  select @membership_request.authorities.first.to_s, from: 'Authority'
  fill_in "Comment", with: "No *membership* for you!"
  click_button "Reject"
end

Then /^I should see the rejected membership_request$/ do
  @membership_request.reload
  within("#flash_notice") { page.should have_text( "Membership request was successfully rejected." ) }
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text "Rejected at: #{@membership_request.rejected_at.to_s(:us_ordinal)}"
    page.should have_text "Rejected by authority: #{@membership_request.authorities.first.name}"
    page.should have_text "Rejected by user: #{@current_user.name(:net_id)}"
    page.should have_text "Reject notice at: None sent."
    page.should have_text "No membership for you!"
  end
end

When /^I reactivate the membership_request$/ do
  Capybara.current_session.driver.submit :put, reactivate_membership_request_url(@membership_request), {}
end

When /^I touch the membership_request$/ do
  Capybara.current_session.driver.submit :put, membership_request_url(@membership_request), {}
end

Then /^the membership_request should be active$/ do
  @membership_request.reload
  @membership_request.active?.should be_true
end

Then /^I should see the reactivated membership_request$/ do
  within("#flash_notice") { page.should have_text "Membership request was successfully reactivated." }
end

When /^the (close|reject) notice has been sent$/ do |notice|
  @membership_request.send "send_#{notice}_notice!"
end

Then /^I should see the (close|reject) notice is sent$/ do |notice|
  visit membership_request_url @membership_request
  within("#membership-request-#{@membership_request.id}") do
    page.should have_text( "#{notice.titleize} notice at: " +
      @membership_request.send("#{notice}_notice_at").to_formatted_s(:long_ordinal) )
  end
end

When /^I move the (\d+)rd membership_request to the position of the (\d+)st membership_request$/ do |from, to|
  step %{I log in as the staff user}
  visit edit_membership_request_url @membership_requests[from.to_i - 1]
  select @membership_requests[to.to_i - 1].committee.name, from: 'Move to'
  click_button 'Update'
end

Then /^the membership_requests should have the following positions:$/ do |table|
  table.diff! @membership_requests.map { |r| r.reload; [ r.position.to_s ] }
end

