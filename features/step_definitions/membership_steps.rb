Given /^#{capture_model} is( not)? interested in renewal$/ do |membership, negate|
  m = model(membership)
  m.update_column :renew_until, ( negate ? nil : ( m.ends_at + 2.years ) )
end

Given /^#{capture_model} is( not)? declined renewal$/ do |membership, negate|
  m = model(membership)
  m.update_column :declined_at, ( negate ? nil : Time.zone.now )
end

Given /^#{capture_model} has( not)? confirmed renewal preference$/ do |membership, negate|
  m = model(membership)
  m.update_column :renewal_confirmed_at, ( negate ? nil : ( Time.zone.now ) )
end

Given /^(?:an )authorization scenario of an? (current|recent|pending|future|past) membership to which I have a (current|recent|pending) (admin|staff|authority|authority_ro|member|plain) relationship$/ do |member_tense, relation_tense, relationship|
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

Then /^I may( not)? create memberships for the position$/ do |negate|
  visit(new_position_membership_url(@position))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    page.should have_text('New membership')
  else
    page.should have_no_text('New membership')
  end
  Capybara.current_session.driver.submit :post, position_memberships_url(@position), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? update the membership$/ do |negate|
  Capybara.current_session.driver.submit :put, membership_url(@membership), {}
  step %{I should#{negate} be authorized}
  visit(edit_membership_url(@membership))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    within("#membership-#{@membership.id}") { page.should have_text('Edit') }
  else
    if page.has_selector?("#membership-#{@membership.id}")
      within("#membership-#{@membership.id}") { page.should have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? destroy the membership$/ do |negate|
  visit(position_memberships_url(@position))
  if negate.blank?
    within("#membership-#{@membership.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, membership_url(@membership), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? see the membership$/ do |negate|
  visit(membership_url(@membership))
  step %{I should#{negate} be authorized}
  visit(position_memberships_url(@position))
  if negate.blank?
    page.should have_selector( "#membership-#{@membership.id}" )
  else
    page.should have_no_selector( "#membership-#{@membership.id}" )
  end
end

When /^I create a membership as (staff|authority)$/ do |relationship|
  role = case relationship
  when 'staff'
    'staff'
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  if relationship == 'authority'
    step %{I have a current #{position_relationship} relationship to the position}
  end
  fill_in 'Name', with: 'Charter amendment'
  fill_in 'Description', with: 'This is a *big* change.'
  fill_in 'Content', with: '*Whereas* and *Resolved*'
  click_link 'add attachment'
  attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
  fill_in 'Attachment description', with: 'Sample employee ids'
  click_button 'Create'
  @membership = Membership.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
  @membership.update_column :published, true
end

Then /^I should see the new membership$/ do
  within('#flash_notice') { page.should have_text('Membership was successfully created.') }
  within("#membership-#{@membership.id}") do
    page.should have_text("Position: Powerful Position")
    page.should have_text("Period: #{@period.to_s}")
    page.should have_text("Name: Charter amendment")
    page.should have_text("Sponsors: George Washington")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Resolved")
    page.should have_text("Sample employee ids")
  end
end

When /^I update the membership$/ do
  click_link "Edit"
  fill_in "Name", with: "Charter change"
  fill_in "Description", with: "This is a big change."
  fill_in "Content", with: "Whereas and Finally Resolved"
  click_link "remove sponsorship"
  click_link "add sponsorship"
  within(".new-sponsorship") do
    fill_in "Sponsor", with: "#{@alternate_sponsor.net_id}"
  end
  click_link "remove attachment"
  click_button "Update"
end

Then /^I should see the edited membership$/ do
  within('#flash_notice') { page.should have_text("Membership was successfully updated.") }
  within("#membership-#{@membership.id}") do
    page.should have_text("Name: Charter change")
    page.should have_text("This is a big change.")
    page.should have_text("Whereas and Finally Resolved")
    page.should have_text("Sponsors: John Adams")
    page.should have_no_text("George Washington")
    page.should have_no_text("Sample employee ids")
  end
end

Given /^I have a referred membership as (vicechair|staff)$/ do |relationship|
  role = case relationship
  when 'staff'
    'staff'
  else
    'plain'
  end
  position_relationship = case relationship
  when 'staff'
    'nonmember'
  else
    relationship
  end
  step %{I log in as the #{role} user}
  step %{I have a current #{position_relationship} relationship to the position}
  @membership = create( :referred_membership, position: @position )
  create(:attachment, attachable: @membership, description: "Sample employee ids")
end

When /^I update the referred membership$/ do
  visit(edit_membership_path(@membership))
  fill_in "Name", with: "Referred membership"
  fill_in "Description", with: "This is different"
  fill_in "Content", with: "Whereas and resolved"
  click_link "remove attachment"
  click_button "Update"
end

Then /^I should see the updated referred membership$/ do
  within('#flash_notice') { page.should have_text("Membership was successfully updated.") }
  within("#membership-#{@membership.id}") do
    page.should have_text("Name: Referred membership")
    page.should have_text("This is different")
    page.should have_text("Whereas and resolved")
    page.should have_no_text("Sample employee ids")
  end
end

Given /^there are (\d+) memberships for a position$/ do |quantity|
  @position = create(:position)
  @memberships = quantity.to_i.downto(1).
    map { |i| create :sponsored_membership, name: "Membership #{i}", position: @position }
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) membership for the position$/ do |text, membership|
  visit(position_memberships_path(@position))
  within("table > tbody > tr:nth-child(#{membership.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following memberships for the position:$/ do |table|
  visit(position_memberships_path(@position))
  table.diff! tableish( 'table#memberships > tbody > tr', 'td:nth-of-type(3)' )
end

