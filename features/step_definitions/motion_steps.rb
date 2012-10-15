#Given /^#{capture_model} is (divided|merged|proposed|rejected|restarted|withdrawn)$/ do |motion, state|
#  case state
#  when 'merged'
#    step "#{motion} is proposed"
#    step "I log out"
#    step "I log in as user: \"chair\""
#    step "I am on the proposed motions page for the committee"
#    step %{a motion: "target" exists with committee: the committee, period: the period, name: "Target", published: true, status: "proposed"}
#    step %{I follow "Merge" within "#motions"}
#    step %{I select "Target" from "Motion"}
#    step %{I press "Merge"}
#  when 'divided'
#    step "#{motion} is proposed"
#    step "I log out"
#    step "I log in as user: \"chair\""
#    step "I am on the proposed motions page for the committee"
#    step "I follow \"Divide\" within \"#motions\""
#    step "I follow \"add dividing motion\""
#    step %{I fill in "Name" with "Charter amendment"}
#    step %{I fill in "Description" with "This is a *big* change."}
#    step %{I fill in "Content" with "*Whereas* and *Resolved*"}
#    step %{I press "Update Motion"}
#  when 'proposed'
#    step "I log in as user: \"sponsor\""
#    step "I follow \"Propose\" within \"#motions\""
#  when 'rejected'
#    step "#{motion} is proposed"
#    step "I log out"
#    step "I log in as user: \"chair\""
#    step "I am on the proposed motions page for the committee"
#    step "I follow \"Reject\" within \"#motions\""
#  when 'withdrawn'
#    step "#{motion} is proposed"
#    step "I log out"
#    step "I log in as user: \"sponsor\""
#    step "I follow \"Withdraw\" within \"#motions\""
#  when 'restarted'
#    step "I log in as user: \"sponsor\""
#    step "I follow \"Restart\" within \"#motions\""
#  end
#end

Given /^I have a (current|past|future) (chair|vicechair|voter|nonvoter|nonmember) relationship to the committee$/ do |tense, relationship|
  @committee = create :committee
  @period = case tense
  when 'current'
    create(:current_period, schedule: @committee.schedule )
  when 'past'
    create(:past_period, schedule: @committee.schedule )
  else
    create(:future_period, schedule: @committee.schedule )
  end
  if relationship != 'nonmember'
    position = create :position, schedule: @committee.schedule
    create :membership, position: position, period: @period, user: @current_user
    enrollment = case relationship
    when 'chair', 'vicechair'
      create :enrollment, manager: true, committee: @committee, position: position
    when 'voter'
      create :enrollment, votes: 1, committee: @committee, position: position
    when 'nonvoter'
      create :enrollment, votes: 0, position: position
    else
      nil
    end
  end
end

Given /^(?:an )authorization scenario of (un)?published, (\w+) motion of (sponsored|referred) origin to which I have a (current|past|future) (admin|staff|chair|vicechair|voter|sponsor|nonvoter|nonmember) relationship$/ do |publication, status, origin, tense, relationship|
  Motion.delete_all
  committee_relationship = case relationship
  when 'sponsor'
    'voter'
  when 'admin', 'staff'
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
  step %{I have a #{tense} #{committee_relationship} relationship to the committee}
  @motion = create "#{origin}_motion".to_sym,  committee: @committee,
    period: @period, status: status, published: publication.blank?
  if relationship == 'sponsor'
    create :sponsorship, motion: @motion, user: @current_user
  end
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
    'nonmember'
  else
    relationship
  end
  step %{I log in as the #{role} user}
  step %{I have a current #{committee_relationship} relationship to the committee}
  if committee_relationship == 'nonmember'
    sponsor_membership = create( :past_membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      user: create( :user, net_id: 'zzz2', first_name: 'George', last_name: 'Washington' ) )
    @period = sponsor_membership.period
    @sponsor = sponsor_membership.user
    @alternate_sponsor = create( :membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      period: @period,
      user: create( :user, net_id: 'zzz1', first_name: 'John', last_name: 'Adams' ) ).user
  else
    @sponsor = @current_user
    @current_user.update_attributes first_name: 'George', last_name: 'Washington'
    @alternate_sponsor = create( :membership,
      position: create( :enrollment, committee: @committee, votes: 1 ).position,
      user: create( :user, net_id: 'zzz1', first_name: 'John', last_name: 'Adams' ) ).user
    @period = @committee.periods.active
  end
  @committee.update_attributes name: 'Powerful Committee'
  visit(new_committee_motion_path(@committee))
  if relationship == 'staff'
    select @period.to_s, from: 'Period'
    fill_in "Sponsor", with: "#{@sponsor.net_id}"
  else
    within("form") { page.should have_no_text('Period') }
  end
  fill_in 'Name', with: 'Charter amendment'
  fill_in 'Description', with: 'This is a *big* change.'
  fill_in 'Content', with: '*Whereas* and *Resolved*'
  click_link 'add attachment'
  attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
  fill_in 'Attachment description', with: 'Sample employee ids'
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
  click_link "remove sponsorship"
  click_link "add sponsorship"
  within(".new-sponsorship") do
    fill_in "Sponsor", with: "#{@alternate_sponsor.net_id}"
  end
  click_link "remove attachment"
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
    'nonmember'
  else
    relationship
  end
  step %{I log in as the #{role} user}
  step %{I have a current #{committee_relationship} relationship to the committee}
  @motion = create( :referred_motion, committee: @committee )
  create(:attachment, attachable: @motion, description: "Sample employee ids")
end

When /^I update the referred motion$/ do
  visit(edit_motion_path(@motion))
  fill_in "Name", with: "Referred motion"
  fill_in "Description", with: "This is different"
  fill_in "Content", with: "Whereas and resolved"
  click_link "remove attachment"
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
  within("#motions") { table.diff!( tableish( 'table > tbody > tr', 'td:nth-child(2)' ) ) }
end

