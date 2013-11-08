Then /^I should (not )?see the motion$/ do |negate|
  if negate.blank?
    page.should have_selector "#motion-#{@motion.id}"
  else
    page.should have_no_selector "#motion-#{@motion.id}"
  end
end

When /^I (adopt|amend|divide|implement|merge|propose|refer|reject|restart|unamend|withdraw) the motion with(out)? attachment$/ do |event, attach|
  @event = event
  case @event
  when 'adopt'
    visit(adopt_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_button 'Adopt'
  when 'amend'
    visit(amend_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    fill_in 'Description', with: 'New description'
    fill_in 'Content', with: 'New content'
    click_button 'Amend'
  when 'divide'
    visit(divide_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_link 'Add Referred Motion'
    fill_in 'Name', with: 'Charter amendment'
    fill_in 'Description', with: 'This is a big change'
    fill_in 'Content', with: 'Whereas and resolved'
    click_button 'Divide'
  when 'implement'
    visit(implement_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_button 'Implement'
  when 'merge'
    create :motion, committee: @motion.committee, period: @motion.period,
      name: 'Target', published: true, status: 'proposed'
    visit(merge_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    select 'Target', from: 'Motion'
    click_button 'Merge'
  when 'propose'
    visit(propose_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_button 'Propose'
  when 'refer'
    other_committee = create( :committee, schedule: @committee.schedule )
    visit(refer_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    fill_in 'Committee', with: other_committee.name
    fill_in 'Name', with: "#{@motion.name} referred"
    click_button 'Refer'
  when 'reject'
    visit(reject_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_button 'Reject'
  when 'restart'
    Capybara.current_session.driver.submit :put, restart_motion_url(@motion), {}
  when 'unamend'
    old_motion = @motion
    step %q{I amend the motion}
    @motion = Motion.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
    step %q{I reject the motion}
    @event = 'unamend'
  when 'withdraw'
    visit(withdraw_motion_path(@motion))
    step "I fill in motion event details with#{attach} attachment"
    click_button 'Withdraw'
  end
end

When /^I fill in motion event details with(out)? attachment$/ do |attach|
  if %w( admin staff ).include? @role
    fill_in 'Event date', with: (Time.zone.today - 1.day).to_formatted_s(:db)
  end
  fill_in 'Event description', with: 'event details'
  if attach.blank?
    click_link 'Add Attachment'
    within_fieldset "Attachments" do
      attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
      fill_in 'Attachment description', with: 'Sample employee ids'
    end
  end
end

Then /^I should see confirmation of the event with(out)? attachment on the motion$/ do |attach|
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
    when 'unamend'; 'rejected'
    when 'withdraw'; 'withdrawn'
  end
  @motion.reload
  @motion.status.should eql new_status
  within(".alert") do
    case @event
    when 'restart'
      page.should have_text "Motion restarted."
    when 'watch'
      page.should have_text "You are now watching the motion."
    when 'unwatch'
      page.should have_text "You are no longer watching the motion."
    else
      page.should have_text "Motion #{new_status}."
    end
  end
  @final_event = case @event
  when 'restart'
    nil
  else
   @motion.motion_events.last
  end
  step "the final motion event should be correctly recorded with#{attach} attachment" if @final_event
  # In case of amendment, propose event should also be recorded on amendment motion
  if %w( amend divide refer ).include? @event
    @motion.referred_motions.each do |referred|
      @final_event = referred.motion_events.last
      @final_event.event.should eql 'propose'
      step "the final motion event should be correctly recorded without attachment"
      within("#ancestors") { page.should have_text @motion.name }
    end
  end
  if %w( unamend ).include? @event
    @final_event = @motion.referring_motion.motion_events.last
    @final_event.event.should eql 'unamend'
    step "the final motion event should be correctly recorded without attachment"
  end
end

Then /^the final motion event should be correctly recorded with(out)? attachment$/ do |attach|
  if %w( admin staff ).include? @role
    @final_event.occurrence.should eql( Time.zone.today - 1.day )
  else
    @final_event.occurrence.should eql Time.zone.today
  end
  @final_event.description.should eql 'event details'
  if attach.blank?
    @final_event.attachments.length.should eql 1
    @final_event.attachments.first.description.should eql 'Sample employee ids'
  else
    @final_event.attachments.should be_empty
  end
end

Given /^(?:an? )(current|future|past) (un)?published, (\w+) motion exists of (sponsored|referred|meeting) origin to which I have a (?:(current|past|future) )?(admin|staff|chair|vicechair|voter|sponsor|nonsponsor|clerk|nonvoter|watcher|commenter|plain|guest) relationship$/ do |motion_tense, publication, status, origin, tense, relationship|
  Motion.delete_all
  committee_relationship = case relationship
  when 'admin', 'staff', 'watcher', 'commenter', 'plain', 'guest'
    nil
  when 'sponsor', 'nonsponsor'
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
  if relationship != 'guest'
    step %{I log in as the #{role} user}
  end
  sponsor_flag = case relationship
  when 'nonsponsor'
    false
  else
    true
  end
  @committee = create( :committee, sponsor: sponsor_flag )
  if committee_relationship
    step %{I have a #{tense} #{committee_relationship} relationship to the committee}
  end
  @period = create( "#{motion_tense}_period".to_sym, schedule: @committee.schedule )
  @motion = create "#{origin}_motion".to_sym, committee: @committee,
    period: @period, status: status, published: publication.blank?
  if relationship == 'sponsor'
    create :sponsorship, motion: @motion, user: @current_user
  end
  if relationship == 'watcher'
    @current_user.watched_motions << @motion
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

Then /^I may( not)? see the motion through public listings$/ do |negate|
  visit(public_motions_url)
  if negate.blank?
    page.should have_selector( "#motion-#{@motion.id}" )
  else
    page.should have_no_selector( "#motion-#{@motion.id}" )
  end
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

When /^I create a motion as (voter|staff|admin)$/ do |relationship|
  @role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  committee_relationship = case relationship
  when 'admin', 'staff'
    nil
  else
    relationship
  end
  step %{I log in as the #{@role} user}
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
  if %w( admin staff ).include? relationship
    select @period.to_s.strip.squeeze(" "), from: 'Period'
    fill_in "Sponsor", with: "#{@sponsor.net_id}"
  else
    within("form") { page.should have_text('You may not change the period of this motion.') }
  end
  fill_in 'Name', with: 'Charter amendment'
  fill_in 'Description', with: 'This is a *big* change.'
  fill_in 'Content', with: '*Whereas* and *Resolved*'
  click_link 'Add Attachment'
  within_fieldset "Attachments" do
    attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
    fill_in 'Attachment description', with: 'Sample employee ids'
  end
  if %w( admin staff ).include? @role
    click_link 'Add Motion Event'
    within_fieldset "Motion Events" do
      fill_in "Event type", with: "withdraw"
      fill_in "Event date", with: Time.zone.today.to_s(:db)
      fill_in "Event description", with: "Fake event"
    end
  end
  click_button 'Create'
  @motion = Motion.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  @motion.update_column :published, true
end

Then /^I should see the new motion$/ do
  within('.alert') { page.should have_text('Motion created.') }
  within("#motion-#{@motion.id}") do
    page.should have_text("Committee: Powerful Committee")
    page.should have_text("Period: #{@period.to_s}")
    page.should have_text("Name: Charter amendment")
    page.should have_text("Sponsors: George Washington")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Resolved")
    page.should have_text("Sample employee ids")
  end
  if %w( admin staff ).include? @role
    within("#motion-events > tbody tr:nth-of-type(1)") do
      within("td:nth-of-type(1)") { page.should have_text Time.zone.today.to_s }
      within("td:nth-of-type(2)") { page.should have_text "withdraw" }
    end
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
  if %w( admin ).include? @role
    click_link "Remove Motion Event"
  else
    page.should have_no_text "Remove Motion Event"
  end
  click_button "Update"
end

Then /^I should see the edited motion$/ do
  within('.alert') { page.should have_text("Motion updated.") }
  within("#motion-#{@motion.id}") do
    page.should have_text("Name: Charter change")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Finally Resolved")
    page.should have_text("Sponsors: John Adams")
    page.should have_no_text("George Washington")
    page.should have_no_text("Sample employee ids")
  end
  if %w( admin plain ).include? @role
    page.should have_no_selector("#motion-events")
  end
end

Given /^I have a referred motion as (vicechair|staff)$/ do |relationship|
  @role = case relationship
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
  step %{I log in as the #{@role} user}
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
  within('.alert') { page.should have_text("Motion updated.") }
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

Then /^I may( not)? create motions for the committee through my dashboard$/ do |negate|
  visit home_url
  if negate.blank?
    within("#new-motions") do
      page.should have_text @committee.name
    end
  else
    if page.has_selector?("#new-motions")
      within("#new-motions") do
        page.should have_no_text
      end
    end
  end
end

Then /^I should( not)? see the motion with the pending meeting$/ do |negate|
  motion_selector = "#motion-#{@motion.id}"
  if negate.present?
    if page.has_selector?(motion_selector)
      within(motion_selector) do
        page.should_not have_selector "a.pending-meeting"
      end
    end
  else
    within(motion_selector) do
      within("a.pending-meeting") do
        page.should have_text "#{@meeting.starts_at.to_s :us_short}"
      end
    end
  end
end

Given /^the motion is scheduled for a pending meeting$/ do
  @meeting = create(:meeting, committee: @motion.committee, period: @motion.period, starts_at: Time.zone.now + 1.day)
  create( :motion_meeting_item, meeting_section: create( :meeting_section, meeting: @meeting ), motion: @motion )
end

