Given /^(?:an )authorization scenario of a brand to which I have an? (admin|staff|plain) relationship$/ do |role|
  step %{I log in as the #{role} user}
  @brand = create( :brand )
end

Then /^I may( not)? see the brand$/ do |negate|
  visit(brand_url(@brand))
  step %{I should#{negate} be authorized}
  visit(brands_url)
  if negate.blank?
    page.should have_selector( "#brand-#{@brand.id}" )
  else
    page.should have_no_selector( "#brand-#{@brand.id}" )
  end
end

Then /^I may( not)? create brands$/ do |negate|
  Capybara.current_session.driver.submit :post, brands_url, {}
  step %{I should#{negate} be authorized}
  visit(new_brand_url)
  step %{I should#{negate} be authorized}
  visit(brands_url)
  if negate.blank?
    page.should have_text('New brand')
  else
    page.should have_no_text('New brand')
  end
end

Then /^I may( not)? update the brand$/ do |negate|
  Capybara.current_session.driver.submit :put, brand_url(@brand), {}
  step %{I should#{negate} be authorized}
  visit(edit_brand_url(@brand))
  step %{I should#{negate} be authorized}
  visit(brands_url)
  if negate.blank?
    within("#brand-#{@brand.id}") { page.should have_text('Edit') }
  else
    page.should have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the brand$/ do |negate|
  visit(brands_url)
  if negate.blank?
    within("#brand-#{@brand.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, brand_url(@brand), {}
  step %{I should#{negate} be authorized}
end

When /^I create an brand$/ do
  visit(new_brand_url)
  fill_in 'Name', with: 'SA brand'
  attach_file 'Logo', File.expand_path('spec/assets/logo.eps')
  fill_in 'Phone', with: "6075551000"
  fill_in 'Fax', with: "2125551000"
  fill_in 'Web', with: "http://example.org"
  fill_in 'Email', with: 'info@example.org'
  fill_in 'Address Line 1', with: '500 Day Hall'
  fill_in 'Address Line 2', with: 'Cornell University'
  fill_in 'City', with: 'Ithaca'
  fill_in 'State', with: 'NY'
  fill_in 'Zip', with: '14850'
  click_button 'Create'
  @brand = Brand.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new brand$/ do
  within( "#flash_notice" ) { page.should have_text( "Brand was successfully created." ) }
  within( "#brand-#{@brand.id}" ) do
    page.should have_text 'Name: SA brand'
    page.should have_text 'Phone: (607) 555-1000'
    page.should have_text 'Fax: (212) 555-1000'
    page.should have_text 'Web: http://example.org'
    page.should have_text 'Email: info@example.org'
    page.should have_text 'Address Line 1: 500 Day Hall'
    page.should have_text 'Address Line 2: Cornell University'
    page.should have_text 'City: Ithaca'
    page.should have_text 'State: NY'
    page.should have_text 'Zip: 14850'
  end
end

When /^I update the brand$/ do
  visit(edit_brand_url(@brand))
  fill_in 'Name', with: 'SA alternative'
  fill_in 'Phone', with: "5551001"
  fill_in 'Fax', with: "2125551001"
  fill_in 'Web', with: "http://example.com"
  fill_in 'Email', with: 'info@example.com'
  fill_in 'Address Line 1', with: '500 Night Hall'
  fill_in 'Address Line 2', with: 'Cornell College'
  fill_in 'City', with: 'Des Moines'
  fill_in 'State', with: 'IA'
  fill_in 'Zip', with: '45505'
  click_button 'Update'
end

Then /^I should see the edited brand$/ do
  within('#flash_notice') { page.should have_text( "Brand was successfully updated." ) }
  within("#brand-#{@brand.id}") do
    page.should have_text 'Name: SA alternative'
    page.should have_text 'Phone: (607) 555-1001'
    page.should have_text 'Fax: (212) 555-1001'
    page.should have_text 'Web: http://example.com'
    page.should have_text 'Email: info@example.com'
    page.should have_text 'Address Line 1: 500 Night Hall'
    page.should have_text 'Address Line 2: Cornell College'
    page.should have_text 'City: Des Moines'
    page.should have_text 'State: IA'
    page.should have_text 'Zip: 45505'
  end
end

Given /^there are (\d+) brands$/ do |quantity|
  @brands = quantity.to_i.downto(1).
    map { |i| create :brand, name: "Brand #{i}" }
end

Given /^I "(.+)" the (\d+)(?:st|nd|rd|th) brand$/ do |text, brand|
  visit(brands_url)
  within("table > tbody > tr:nth-child(#{brand.to_i})") do
    click_link "#{text}"
  end
end

Then /^I should see the following brands:$/ do |table|
  within("#flash_notice") { page.should have_text("Brand was successfully destroyed.") }
  visit(brands_url)
  table.diff! tableish( 'table#brands > tbody > tr', 'td:nth-of-type(1)' )
end

