Given /^(?:an )authorization scenario of an? (current|recent|pending|future|past|historic) membership to which I have a (?:(current|recent|pending|future) )?(admin|staff|authority|authority_ro|member|plain) relationship$/ do |member_tense, relation_tense, relationship|
  role = case relationship
  when 'admin', 'staff'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @position = create( :position )
  if %w( authority authority_ro ).include?( relationship )
    step %{I have a #{relation_tense} #{relationship} relationship to the position}
  end
  user = case relationship
  when 'member'
    @current_user
  else
    create(:user)
  end
  period = case member_tense
  when 'recent', 'pending', 'current'
    create( :current_period, schedule: @position.schedule )
  when 'historic'
    past = create( :past_period, schedule: @position.schedule )
    create( :period, schedule: @position.schedule, ends_at: ( past.starts_at - 1.day ),
      starts_at: ( past.starts_at - 1.year ) )
  else
    create( :current_period, schedule: @position.schedule )
    create( "#{member_tense}_period", schedule: @position.schedule )
  end
  @membership = case member_tense
  when 'recent'
    create(:membership, position: @position, user: user, period: period, ends_at: ( Time.zone.today - 1.day ) )
  when 'pending'
    create(:membership, position: @position, user: user, period: period, starts_at: ( Time.zone.today + 1.day ) )
  else
    create(:membership, position: @position, user: user, period: period )
  end
end

Given /^the position is( not)? renewable$/ do |negate|
  @position.update_column :renewable, ( negate.blank? ? true : false )
end

Given /^the member has( not)? requested renewal to (next day|today|tomorrow)$/ do |negate, tense|
  if negate.blank?
    @membership.update_column :renew_until, case tense
    when 'next day'
      @membership.ends_at + 1.day
    when 'today'
      Time.zone.today
    when 'tomorrow'
      Time.zone.today + 1.day
    end
  end
end

Then /^I may( not)? create memberships for the position$/ do |negate|
  visit(new_position_membership_url(@position))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    expect( page ).to have_text('New membership')
  else
    expect( page ).to have_no_text('New membership')
  end
  Capybara.current_session.driver.submit :post,
    position_memberships_url(@position),
    { "membership" => { "starts_at" => "" } }
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? update the membership$/ do |negate|
  Capybara.current_session.driver.submit :put, membership_url(@membership),
    { "membership" => { "starts_at" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_membership_url(@membership))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    within("#membership-#{@membership.id}") { expect( page ).to have_text('Edit') }
  else
    if page.has_selector?("#membership-#{@membership.id}")
      within("#membership-#{@membership.id}") { expect( page ).to have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? destroy the membership$/ do |negate|
  visit(position_memberships_url(@position))
  if negate.blank?
    within("#membership-#{@membership.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, membership_url(@membership), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? see the membership$/ do |negate|
  visit(membership_url(@membership))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    expect( page ).to have_selector( "#membership-#{@membership.id}" )
  else
    expect( page ).to have_no_selector( "#membership-#{@membership.id}" )
  end
end

Then /^I may( not)? review the membership$/ do |negate|
  visit(assigned_reviewable_memberships_url)
  if negate.blank?
    expect( page ).to have_selector( "#membership-#{@membership.id}" )
  else
    expect( page ).to have_no_selector( "#membership-#{@membership.id}" )
  end
end

Then /^I may( not)? decline the membership$/ do |negate|
  visit(position_memberships_url(@position))
  if negate.blank?
    within("#membership-#{@membership.id}") { expect( page ).to have_text('Decline') }
  else
    if page.has_selector?("#membership-#{@membership.id}")
      within("#membership-#{@membership.id}") { expect( page ).to have_no_text('Decline') }
    end
  end
  visit(decline_membership_url(@membership))
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? review the membership for renewal$/ do |negate|
  visit renewable_reviewable_memberships_path
  if negate.blank?
    expect( page ).to have_selector "#membership-#{@membership.id}"
  else
    expect( page ).to have_no_selector "#membership-#{@membership.id}"
  end
end

When /^I attempt to create a (past|current|future|pending|recent) membership as (?:(current|pending|future) )?(staff|authority)$/ do |member_tense, relation_tense, relation|
  role = case relation
  when 'staff'
    'staff'
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @position = create(:position, designable: true)
  create(:enrollment, position: @position, committee: create(:committee, name: 'Important Committee'))
  @past_period = create(:past_period, schedule: @position.schedule)
  @current_period = create(:period, schedule: @position.schedule)
  @future_period = create(:future_period, schedule: @position.schedule)
  @period = case member_tense
  when 'past'
    @past_period
  when 'future'
    @future_period
  else
    @current_period
  end
  @starts_at = case member_tense
  when 'pending'
    Time.zone.today + 1.day
  else
    @period.starts_at
  end
  @ends_at = case member_tense
  when 'recent'
    Time.zone.today - 1.day
  else
    @period.ends_at
  end
  @candidate = create(:user, net_id: 'zzz998')
  @designee = create(:user, net_id: 'zzz999')
  if relation == 'authority'
    step %{I have a #{relation_tense} #{relation} relationship to the position}
  end
  visit new_position_membership_path(@position)
  fill_in 'User', with: @candidate.name(:net_id)
  select @period.to_s.strip.squeeze(" "), from: "Period"
  fill_in 'Starts at', with: @starts_at.to_s(:db)
  fill_in 'Ends at', with: @ends_at.to_s(:db)
  fill_in "Designee for Important Committee", with: @designee.name(:net_id)
  click_button 'Create'
end

Then /^I should( not)? see the modifier error message$/ do |negate|
  if negate.blank?
    within(".error_messages") { expect( page ).to have_text "must have authority to modify the position between" }
  else
    @membership = Membership.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
    within('.alert') { expect( page ).to have_text('Membership created.') }
  end
end

Then /^I should see the new membership$/ do
  within("#membership-#{@membership.id}") do
    expect( page ).to have_text("Position: #{@position.name}")
    expect( page ).to have_text("Period: #{@period.to_s}")
    expect( page ).to have_text("User: #{@candidate.name(:net_id)}")
    expect( page ).to have_text("Starts at: #{@starts_at.to_formatted_s(:us_ordinal)}")
    expect( page ).to have_text("Ends at: #{@ends_at.to_formatted_s(:us_ordinal)}")
    expect( page ).to have_text("Designee for Important Committee: #{@designee.name(:net_id)}")
  end
end

When /^I update the membership$/ do
  visit edit_membership_path(@membership)
  fill_in 'User', with: @designee.name(:net_id)
  @starts_at += 1.day
  @ends_at -= 1.day
  fill_in 'Starts at', with: @starts_at.to_s(:db)
  fill_in 'Ends at', with: @ends_at.to_s(:db)
  fill_in 'Designee for Important Committee', with: @candidate.name(:net_id)
  click_button 'Update'
end

Then /^I should see the edited membership$/ do
  within('.alert') { expect( page ).to have_text("Membership updated.") }
  within("#membership-#{@membership.id}") do
    expect( page ).to have_text("User: #{@designee.name(:net_id)}")
    expect( page ).to have_text("Starts at: #{@starts_at.to_formatted_s(:us_ordinal)}")
    expect( page ).to have_text("Ends at: #{@ends_at.to_formatted_s(:us_ordinal)}")
    expect( page ).to have_text("Designee for Important Committee: #{@candidate.name(:net_id)}")
  end
end

Given /^there are (\d+) memberships for a position by (end|start|last|first)$/ do |quantity, column|
  @period = create(:period, starts_at: '2011-01-01', ends_at: '2011-12-31')
  @position = create(:position, slots: quantity.to_i, minimum_slots: 0,
    schedule: @period.schedule)
  @memberships = quantity.to_i.downto(1).map do |i|
    case column
    when 'last'
      create :membership, position: @position, user: create( :user, last_name: "Doe1000#{i}" )
    when 'first'
      create :membership, position: @position, user: create( :user, first_name: "John1000#{i}" )
    when 'start'
      create :membership, position: @position, starts_at: ( @period.starts_at + (quantity.to_i - i).days )
    when 'end'
      create :membership, position: @position, ends_at: ( @period.ends_at - i.days )
    end
  end
end

Given /^there are (\d+) memberships with a common (position|authority|user|committee)$/ do |quantity, common|
  @common = case common
  when 'position'
    create(:position, slots: quantity.to_i, minimum_slots: 0)
  else
    create(common.to_sym)
  end
  @memberships = quantity.to_i.times.inject([]) do |memo|
    memo << case common
    when 'position'
      create(:membership, position: @common)
    when 'authority'
      create(:membership, position: create(:position, authority: @common))
    when 'user'
      create(:membership, user: @common)
    when 'committee'
      create(:membership, position: create(:enrollment, committee: @common).position)
    end
  end
end

When /^I search for the (position|authority|user|committee) of the (\d+)(?:st|nd|rd|th) membership$/ do |field, position|
  visit polymorphic_url( [ @common, :memberships ] )
  pos = ( position.to_i - 1 )
  case field
  when 'position'
    fill_in 'Position', with: @memberships[pos].position.name
  when 'authority'
    fill_in 'Authority', with: @memberships[pos].position.authority.name
  when 'user'
    fill_in 'User', with: @memberships[pos].user.net_id
  when 'committee'
    fill_in 'Committee',
      with: create(:enrollment, position: @memberships[pos].position).committee.name
  end
end

Then /^I should only find the (\d+)(?:st|nd|rd|th) membership$/ do |position|
  click_button "Search"
  pos = ( position.to_i - 1 )
  needle = @memberships[pos].id
  within("#memberships") do
    ( @memberships.map(&:id) - [ needle ] ).each do |id|
      expect( page ).to_not have_selector "#membership-#{id}"
    end
    expect( page ).to have_selector "#membership-#{needle}"
  end
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) membership for the position$/ do |text, membership|
  visit(position_memberships_path(@position))
  within("table > tbody > tr:nth-child(#{membership.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following memberships for the position:$/ do |table|
  visit(position_memberships_path(@position))
  table.diff! tableish( 'table#memberships > tbody > tr', 'td' )
end

When /^I decline the membership$/ do
  visit decline_membership_url(@membership)
  fill_in "Comment", with: "No *membership* for you!"
  click_button "Decline Renewal"
end

Then /^I should see the membership declined$/ do
  @membership.reload
  within(".alert") { expect( page ).to have_text( "Membership renewal declined." ) }
  within("#membership-#{@membership.id}") do
    expect( page ).to have_text "Renewal declined at: #{@membership.declined_at.to_s(:long_ordinal)}"
    expect( page ).to have_text "Renewal declined by: #{@current_user.name(:net_id)}"
    expect( page ).to have_text "No membership for you!"
  end
end

When /^the (join|leave) notice has been sent$/ do |notice|
  @membership.send "send_#{notice}_notice!"
end

Then /^I should see the (join|leave) notice is sent$/ do |notice|
  visit membership_url @membership
  within("#membership-#{@membership.id}") do
    within("#notices") do
      expect( page ).to have_text notice
    end
  end
end

Given /^the membership is( not)? renewable$/ do |unrenewable|
  if unrenewable.blank?
    @membership.position.update_column :renewable, true
  else
    @membership.position.update_column :renewable, false
  end
  @original_renewal_checkpoint = @membership.user.renewal_checkpoint - 2.weeks
  @membership.user.update_column :renewal_checkpoint, @original_renewal_checkpoint
end

When /^I fill in (a|no) renewal for the membership$/ do |v|
  visit renew_user_memberships_path( @membership.user )
  fill_in "#{@membership.position.name}",
    with: ( v == 'a' ? ( @membership.ends_at + 1.year ).to_formatted_s(:db) : '' )
end

When /^I submit renewals with renotification (en|dis)abled$/ do |renotify|
  within_control_group "Notify again?" do
    choose( renotify == 'en' ? "Yes" : "No" )
  end
  click_button 'Update renewals'
end

Then /^the membership should have (a|no) renewal$/ do |renotify|
  @membership.reload
  expect( @membership.renew_until ).to case renotify
  when 'a'
    eql @membership.ends_at + 1.year
  when 'no'
    be_nil
  end
end

Then /^I should see renewals confirmed with renotification (en|dis)abled$/ do |renotify|
  within(".alert") { expect( page ).to have_text "Renewal preferences updated." }
  @membership.user.reload
  checkpoint = @membership.user.renewal_checkpoint.to_i
  if renotify == 'en'
    target = @original_renewal_checkpoint.to_i
    expect( checkpoint ).to be >= target - 1
    expect( checkpoint ).to be <= target + 1
  else
    target = Time.zone.now.to_i
    expect( checkpoint ).to be >= target - 1.minute.to_i
    expect( checkpoint ).to be <= target + 1.minute.to_i
  end
end

Then /^I may( not)? renew the membership$/ do |negate|
  visit renew_user_memberships_url @membership.user
  if negate.blank?
    expect( page ).to have_control_group "#{@membership.position.name}"
  else
    expect( page ).to have_no_control_group "#{@membership.position.name}"
  end
end

