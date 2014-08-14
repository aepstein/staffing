Given /^(?:an )authorization scenario of a question to which I have an? (admin|staff|plain) relationship$/ do |role|
  step %{I log in as the #{role} user}
  @question = create( :question )
end

Then /^I may( not)? see the question$/ do |negate|
  visit(question_url(@question))
  step %{I should#{negate} be authorized}
  visit(questions_url)
  if negate.blank?
    expect( page ).to have_selector( "#question-#{@question.id}" )
  else
    expect( page ).to have_no_selector( "#question-#{@question.id}" )
  end
end

Then /^I may( not)? create questions$/ do |negate|
  Capybara.current_session.driver.submit :post, questions_url,
    { "question" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_question_url)
  step %{I should#{negate} be authorized}
  visit(questions_url)
  if negate.blank?
    expect( page ).to have_text('New question')
  else
    expect( page ).to have_no_text('New question')
  end
end

Then /^I may( not)? update the question$/ do |negate|
  Capybara.current_session.driver.submit :put, question_url(@question),
    { "question" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_question_url(@question))
  step %{I should#{negate} be authorized}
  visit(questions_url)
  if negate.blank?
    within("#question-#{@question.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the question$/ do |negate|
  visit(questions_url)
  if negate.blank?
    within("#question-#{@question.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, question_url(@question), {}
  step %{I should#{negate} be authorized}
end

When /^I create a question$/ do
  visit(new_question_path)
  fill_in "Name", with: "Favorite color"
  fill_in "Content", with: "What is your favorite color?"
  select "Text Box", from: "Disposition"
  within_control_group("Global?") { choose "Yes" }
  click_button 'Create'
  @question = Question.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new question$/ do
  within( ".alert" ) { expect( page ).to have_text( "Question created." ) }
  within( "#question-#{@question.id}" ) do
    expect( page ).to have_text "Name: Favorite color"
    expect( page ).to have_text "What is your favorite color?"
    expect( page ).to have_text "Text Box"
  end
end

When /^I update the question$/ do
  visit(edit_question_path(@question))
  fill_in "Name", with: "Favorite dessert"
  fill_in "Content", with: "What is your favorite dessert?"
  select "Yes/No", from: "Disposition"
  within_control_group("Global?") { choose "No" }
  click_button 'Update'
end

Then /^I should see the edited question$/ do
  within('.alert') { expect( page ).to have_text( "Question updated." ) }
  within("#question-#{@question.id}") do
    expect( page ).to have_text "Name: Favorite dessert"
    expect( page ).to have_text "What is your favorite dessert?"
    expect( page ).to have_text "Disposition: Yes/No"
    expect( page ).to have_text "Global? No"
  end
end

Given /^there are (\d+) questions$/ do |quantity|
  @questions = quantity.to_i.downto(1).
    map { |i| create :question, name: "Question #{i}", content: "Are you #{11 + i}?" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) question$/ do |text, question|
  visit(questions_url)
  within("table > tbody > tr:nth-child(#{question.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Question destroyed.") }
end

Then /^I should see the following questions:$/ do |table|
  table.diff! tableish( 'table#questions > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for questions with (name|content) "([^"]+)"$/ do |what, needle|
  visit(questions_url)
  fill_in what.titleize, with: needle
  click_button "Search"
end

