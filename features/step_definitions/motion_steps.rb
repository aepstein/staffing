Then /^I should (not )?see the motion$/ do |negate|
  if negate.blank?
    page.should have_selector "#motion-#{@motion.id}"
  else
    page.should have_no_selector "#motion-#{@motion.id}"
  end
end

When /^I (adopt|amend|divide|implement|merge|propose|refer|reject|restart|withdraw) the motion$/ do |event|
  @event = event
  case @event
  when 'adopt'
    visit(adopt_motion_path(@motion))
    fill_in 'Adopt date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_button 'Adopt'
  when 'amend'
    visit(amend_motion_path(@motion))
    fill_in 'Amend date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    fill_in 'Description', with: 'New description'
    fill_in 'Content', with: 'New content'
    click_button 'Amend'
  when 'divide'
    visit(divide_motion_path(@motion))
    fill_in 'Divide date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_link 'add dividing motion'
    fill_in 'Name', with: 'Charter amendment'
    fill_in 'Description', with: 'This is a big change'
    fill_in 'Content', with: 'Whereas and resolved'
    click_button 'Divide'
  when 'implement'
    visit(implement_motion_path(@motion))
    fill_in 'Implement date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_button 'Implement'
  when 'merge'
    create :motion, committee: @motion.committee, period: @motion.period,
      name: 'Target', published: true, status: 'proposed'
    visit(merge_motion_path(@motion))
    fill_in 'Merge date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    select 'Target', from: 'Motion'
    click_button 'Merge'
  when 'propose'
    visit(propose_motion_path(@motion))
    fill_in 'Propose date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_button 'Propose'
  when 'refer'
    other_committee = create( :committee, schedule: @committee.schedule )
    visit(refer_motion_path(@motion))
    fill_in 'Refer date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    fill_in 'Committee', with: other_committee.name
    fill_in 'Name', with: "#{@motion.name} referred"
    click_button 'Refer'
  when 'reject'
    visit(reject_motion_path(@motion))
    fill_in 'Reject date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_button 'Reject'
  when 'restart'
    Capybara.current_session.driver.submit :put, restart_motion_url(@motion), {}
  when 'withdraw'
    visit(withdraw_motion_path(@motion))
    fill_in 'Withdraw date', with: Time.zone.today.to_formatted_s(:db)
    fill_in 'Event description', with: 'event details'
    click_button 'Withdraw'
  end
end

Then /^I should see confirmation of the event on the motion$/ do
  new_status = case @event
    when 'adopt'; 'adopted'
    when 'amend'; 'amended'
    when 'divide'; 'divided'
    when 'implement'; 'implemented'
    when 'merge'; 'merged'
    when 'propose'; 'proposed'
    when 'refer'; 'referred'
    when 'reject'; 'rejected'
    when 'restart'; 'started'
    when 'withdraw'; 'withdrawn'
  end
  @motion.reload
  @motion.status.should eql new_status
  within("#flash_notice") do
    case @event
    when 'restart'
      page.should have_text "Motion was successfully restarted."
    when 'watch'
      page.should have_text "You are now watching the motion."
    when 'unwatch'
      page.should have_text "You are no longer watching the motion."
    else
      page.should have_text "Motion was successfully #{new_status}."
    end
  end
  unless %w( restart amend ).include?( @event )
    final_event = @motion.motion_events.last
    final_event.occurrence.should eql Time.zone.today
    final_event.description.should eql 'event details'
  end
end

Given /^(?:an )authorization scenario of a (current|future|past) (un)?published, (\w+) motion of (sponsored|referred) origin to which I have a (?:(current|past|future) )?(admin|staff|chair|vicechair|voter|sponsor|nonvoter|plain) relationship$/ do |motion_tense, publication, status, origin, tense, relationship|
  Motion.delete_all
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
  @period = create( "#{motion_tense}_period".to_sym, schedule: @committee.schedule )
  @motion = create "#{origin}_motion".to_sym, committee: @committee,
    period: @period, status: status, published: publication.blank?
  if relationship == 'sponsor'
    create :sponsorship, motion: @motion, user: @current_user
  end
end

Then /^I may( not)? (adopt|amend|divide|implement|merge|propose|refer|reject|restart|(?:un)?watch|withdraw) the motion$/ do |negate, event|
  visit(committee_motions_url(@committee))
  if negate.blank?
    within("#motion-#{@motion.id}") { page.should have_text(event.titleize) }
  else
    if page.has_selector?("#motion-#{@motion.id}")
      within("#motion-#{@motion.id}") { page.should have_no_text(event.titleize) }
    end
  end
  unless Motion::EVENTS_PUTONLY.include?( event.to_sym )
    visit(send("#{event}_motion_path", @motion))
    step %{I should#{negate} be authorized}
  end
  Capybara.current_session.driver.submit :put, send("#{event}_motion_url", @motion), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? create motions for the committee$/ do |negate|
  Capybara.current_session.driver.submit :post, committee_motions_url(@committee), {}
  step %{I should#{negate} be authorized}
  visit(new_committee_motion_url(@committee))
  step %{I should#{negate} be authorized}
  visit(committee_motions_url(@committee))
  if negate.blank?
    page.should have_text('New motion')
  else
    page.should have_no_text('New motion')
  end
end

Then /^I may( not)? update the motion$/ do |negate|
  Capybara.current_session.driver.submit :put, motion_url(@motion), {}
  step %{I should#{negate} be authorized}
  visit(edit_motion_url(@motion))
  step %{I should#{negate} be authorized}
  visit(committee_motions_url(@committee))
  if negate.blank?
    within("#motion-#{@motion.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the motion$/ do |negate|
  visit(committee_motions_url(@committee))
  if negate.blank?
    within("#motion-#{@motion.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, motion_url(@motion), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? see the motion$/ do |negate|
  visit(motion_url(@motion))
  step %{I should#{negate} be authorized}
  visit(committee_motions_url(@committee))
  if negate.blank?
    page.should have_selector( "#motion-#{@motion.id}" )
  else
    page.should have_no_selector( "#motion-#{@motion.id}" )
  end
end

When /^I create a motion as (voter|staff)$/ do |relationship|
  role = case relationship
  when 'staff'
    'staff'
  else
    'plain'
  end
  committee_relationship = case relationship
  when 'staff'
    nil
  else
    relationship
  end
  step %{I log in as the #{role} user}
  @committee = create :committee
  if committee_relationship
    step %{I have a current #{committee_relationship} relationship to the committee}
    @sponsor = @current_user
    @current_user.update_attributes first_name: 'George', last_name: 'Washington'
    @alternate_sponsor = create( :membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      user: create( :user, net_id: 'zzz1', first_name: 'John', last_name: 'Adams' ) ).user
    @period = @committee.periods.active
  else
    sponsor_membership = create( :past_membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      user: create( :user, net_id: 'zzz2', first_name: 'George', last_name: 'Washington' ) )
    @period = sponsor_membership.period
    @sponsor = sponsor_membership.user
    @alternate_sponsor = create( :membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      period: @period,
      user: create( :user, net_id: 'zzz1', first_name: 'John', last_name: 'Adams' ) ).user
  end
  @committee.update_attributes name: 'Powerful Committee'
  visit(new_committee_motion_path(@committee))
  if relationship == 'staff'
    select @period.to_s.strip.squeeze(" "), from: 'Period'
    fill_in "Sponsor", with: "#{@sponsor.net_id}"
  else
    within("form") { page.should have_no_text('Period') }
  end
  fill_in 'Name', with: 'Charter amendment'
  fill_in 'Description', with: 'This is a *big* change.'
  fill_in 'Content', with: '*Whereas* and *Resolved*'
  click_link 'Add Attachment'
  within_fieldset "Attachment" do
    attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
    fill_in 'Attachment description', with: 'Sample employee ids'
  end
  click_button 'Create'
  @motion = Motion.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  @motion.update_column :published, true
end

Then /^I should see the new motion$/ do
  within('#flash_notice') { page.should have_text('Motion was successfully created.') }
  within("#motion-#{@motion.id}") do
    page.should have_text("Committee: Powerful Committee")
    page.should have_text("Period: #{@period.to_s}")
    page.should have_text("Name: Charter amendment")
    page.should have_text("Sponsors: George Washington")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Resolved")
    page.should have_text("Sample employee ids")
  end
end

When /^I update the motion$/ do
  click_link "Edit"
  fill_in "Name", with: "Charter change"
  fill_in "Description", with: "This is a big change."
  fill_in "Content", with: "Whereas and Finally Resolved"
  click_link "Remove Sponsorship"
  click_link "Add Sponsorship"
  within_fieldset("New Sponsorship") do
    fill_in "Sponsor", with: "#{@alternate_sponsor.net_id}"
  end
  click_link "Remove Attachment"
  click_button "Update"
end

Then /^I should see the edited motion$/ do
  within('#flash_notice') { page.should have_text("Motion was successfully updated.") }
  within("#motion-#{@motion.id}") do
    page.should have_text("Name: Charter change")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Finally Resolved")
    page.should have_text("Sponsors: John Adams")
    page.should have_no_text("George Washington")
    page.should have_no_text("Sample employee ids")
  end
end

Given /^I have a referred motion as (vicechair|staff)$/ do |relationship|
  role = case relationship
  when 'staff'
    'staff'
  else
    'plain'
  end
  committee_relationship = case relationship
  when 'staff'
    nil
  else
    relationship
  end
  step %{I log in as the #{role} user}
  @committee = create :committee
  if committee_relationship
    step %{I have a current #{committee_relationship} relationship to the committee}
  end
  @motion = create( :referred_motion, committee: @committee )
  create(:attachment, attachable: @motion, description: "Sample employee ids")
end

When /^I update the referred motion$/ do
  visit(edit_motion_path(@motion))
  fill_in "Name", with: "Referred motion"
  fill_in "Description", with: "This is different"
  fill_in "Content", with: "Whereas and resolved"
  click_link "Remove Attachment"
  click_button "Update"
end

Then /^I should see the updated referred motion$/ do
  within('#flash_notice') { page.should have_text("Motion was successfully updated.") }
  within("#motion-#{@motion.id}") do
    page.should have_text("Name: Referred motion")
    page.should have_text("This is different")
    page.should have_text("Whereas and resolved")
    page.should have_no_text("Sample employee ids")
  end
end

Given /^there are (\d+) motions for a committee$/ do |quantity|
  @committee = create(:committee)
  @motions = quantity.to_i.downto(1).
    map { |i| create :sponsored_motion, name: "Motion #{i}", committee: @committee }
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) motion for the committee$/ do |text, motion|
  visit(committee_motions_path(@committee))
  within("table > tbody > tr:nth-child(#{motion.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following motions for the committee:$/ do |table|
  visit(committee_motions_path(@committee))
  table.diff! tableish( 'table#motions > tbody > tr', 'td:nth-of-type(3)' )
end

