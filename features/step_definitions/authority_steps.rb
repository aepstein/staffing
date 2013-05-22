Then /^I should (not )?see the authority$/ do |negate|
  if negate.blank?
    page.should have_selector "#authority-#{@authority.id}"
  else
    page.should have_no_selector "#authority-#{@authority.id}"
  end
end

Given /^(?:an )authorization scenario of an authority to which I have an? (?:(past|current|future|recent|pending) )?(admin|staff|plain|authority|authority_ro) relationship$/ do |tense, relationship|
  role = case relationship
  when 'admin', 'staff', 'plain'
    relationship
  else
    'plain'
  end
  step %{I log in as the #{role} user}
  @authority = create( :authority )
  if relationship =~ /^authority/
    enrollment = if relationship == 'authority'
      create(:enrollment, votes: 1)
    else
      create(:enrollment, votes: 0)
    end
    @authority.committee = enrollment.committee
    @authority.save!
    @position = enrollment.position
    step %{I have a #{tense} member relationship to the position}
  end
end

Then /^I may( not)? see the authority$/ do |negate|
  visit(authority_url(@authority))
  step %{I should#{negate} be authorized}
  visit(authorities_url)
  if negate.blank?
    page.should have_selector( "#authority-#{@authority.id}" )
  else
    page.should have_no_selector( "#authority-#{@authority.id}" )
  end
end

Then /^I may( not)? create authorities$/ do |negate|
  Capybara.current_session.driver.submit :post, authorities_url, {}
  step %{I should#{negate} be authorized}
  visit(new_authority_url)
  step %{I should#{negate} be authorized}
  visit(authorities_url)
  if negate.blank?
    page.should have_text('New authority')
  else
    page.should have_no_text('New authority')
  end
end

Then /^I may( not)? update the authority$/ do |negate|
  Capybara.current_session.driver.submit :put, authority_url(@authority), {}
  step %{I should#{negate} be authorized}
  visit(edit_authority_url(@authority))
  step %{I should#{negate} be authorized}
  visit(authorities_url)
  if negate.blank?
    within("#authority-#{@authority.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the authority$/ do |negate|
  visit(authorities_url)
  if negate.blank?
    within("#authority-#{@authority.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, authority_url(@authority), {}
  step %{I should#{negate} be authorized}
end

When /^I create an authority$/ do
  create :committee, name: "First committee"
  create :committee, name: "Second committee"
  visit(new_authority_url)
  fill_in 'Name', with: 'Supreme Authority'
  fill_in 'Committee', with: 'First committee'
  fill_in 'Appoint message', with: 'You will soon be in the *committee*.'
  fill_in 'Join message', with: 'Welcome to *committee*.'
  fill_in 'Leave message', with: 'You were *dropped* from the committee.'
  fill_in 'Reject message', with: 'There were *no* slots.'
  click_button 'Create'
  @authority = Authority.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new authority$/ do
  within( ".alert" ) { page.should have_text( "Authority created." ) }
  within( "#authority-#{@authority.id}" ) do
    page.should have_text("Name: Supreme Authority")
    page.should have_text("Committee: First committee")
    page.should have_text 'You will soon be in the committee.'
    page.should have_text("Welcome to committee.")
    page.should have_text("You were dropped from the committee.")
    page.should have_text("There were no slots.")
  end
end

When /^I update the authority$/ do
  visit(edit_authority_url(@authority))
  fill_in 'Name', with: 'Subordinate Authority'
  fill_in 'Committee', with: 'Second committee'
  fill_in 'Appoint message', with: 'Pre-welcome message'
  fill_in 'Join message', with: 'Welcome message'
  fill_in 'Leave message', with: 'Farewell message'
  fill_in 'Reject message', with: 'There were not enough slots.'
  click_button 'Update'
end

Then /^I should see the edited authority$/ do
  within('.alert') { page.should have_text( "Authority updated." ) }
  within("#authority-#{@authority.id}") do
    page.should have_text("Name: Subordinate Authority")
    page.should have_text("Committee: Second committee")
    page.should have_text 'Pre-welcome message'
    page.should have_text("Welcome message")
    page.should have_text("Farewell message")
    page.should have_text("There were not enough slots.")
  end
end

Given /^there are (\d+) authorities$/ do |quantity|
  @authorities = quantity.to_i.downto(1).
    map { |i| create :authority, name: "Authority #{i}" }
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) authority$/ do |text, authority|
  visit(authorities_url)
  within("table > tbody > tr:nth-child(#{authority.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following authorities:$/ do |table|
  within(".alert") { page.should have_text("Authority destroyed.") }
  visit(authorities_url)
  table.diff! tableish( 'table#authorities > tbody > tr', 'td:nth-of-type(1)' )
end

