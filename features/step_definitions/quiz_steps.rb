Given /^(?:an )authorization scenario of a quiz to which I have an? (admin|staff|plain) relationship$/ do |role|
  step %{I log in as the #{role} user}
  @quiz = create( :quiz )
end

Then /^I may( not)? see the quiz$/ do |negate|
  visit(quiz_url(@quiz))
  step %{I should#{negate} be authorized}
  visit(quizzes_url)
  if negate.blank?
    expect( page ).to have_selector( "#quiz-#{@quiz.id}" )
  else
    expect( page ).to have_no_selector( "#quiz-#{@quiz.id}" )
  end
end

Then /^I may( not)? create quizzes$/ do |negate|
  Capybara.current_session.driver.submit :post, quizzes_url,
    { "quiz" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(new_quiz_url)
  step %{I should#{negate} be authorized}
  visit(quizzes_url)
  if negate.blank?
    expect( page ).to have_text('New quiz')
  else
    expect( page ).to have_no_text('New quiz')
  end
end

Then /^I may( not)? update the quiz$/ do |negate|
  Capybara.current_session.driver.submit :put, quiz_url(@quiz),
    { "quiz" => { "name" => "" } }
  step %{I should#{negate} be authorized}
  visit(edit_quiz_url(@quiz))
  step %{I should#{negate} be authorized}
  visit(quizzes_url)
  if negate.blank?
    within("#quiz-#{@quiz.id}") { expect( page ).to have_text('Edit') }
  else
    expect( page ).to have_no_text('Edit')
  end
end

Then /^I may( not)? destroy the quiz$/ do |negate|
  visit(quizzes_url)
  if negate.blank?
    within("#quiz-#{@quiz.id}") { expect( page ).to have_text('Destroy') }
  else
    expect( page ).to have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, quiz_url(@quiz), {}
  step %{I should#{negate} be authorized}
end

When /^I create a quiz$/ do
  create(:question, name: 'An Interesting Question')
  create(:question, name: 'The Dull Question')
  visit(new_quiz_path)
  fill_in "Name", with: "Generic"
  click_link 'Add Quiz Question'
  within_fieldset("New Question") do
    select 'An Interesting Question', from: "Question"
  end
  click_button 'Create'
  @quiz = Quiz.find( URI.parse(current_url).path.match(/[\d]+$/)[0].to_i )
end

Then /^I should see the new quiz$/ do
  within( ".alert" ) { expect( page ).to have_text( "Quiz created." ) }
  within( "#quiz-#{@quiz.id}" ) do
    expect( page ).to have_text "Name: Generic"
    within("#questions") do
      expect( page ).to have_text "An Interesting Question"
    end
  end
end

When /^I update the quiz$/ do
  visit(edit_quiz_path(@quiz))
  fill_in "Name", with: "Specialized"
  click_link "Remove Question"
  click_button 'Update'
end

Then /^I should see the edited quiz$/ do
  within('.alert') { expect( page ).to have_text( "Quiz updated." ) }
  within("#quiz-#{@quiz.id}") do
    expect( page ).to have_text "Name: Specialized"
    expect( page ).to have_text "No questions."
  end
end

Given /^there are (\d+) quizzes$/ do |quantity|
  @quizzes = quantity.to_i.downto(1).
    map { |i| create :quiz, name: "Quiz #{i}" }
end

When /^I "(.+)" the (\d+)(?:st|nd|rd|th) quiz$/ do |text, quiz|
  visit(quizzes_url)
  within("table > tbody > tr:nth-child(#{quiz.to_i})") do
    click_link "#{text}"
  end
  within(".alert") { expect( page ).to have_text("Quiz destroyed.") }
end

Then /^I should see the following quizzes:$/ do |table|
  table.diff! tableish( 'table#quizzes > tbody > tr', 'td:nth-of-type(1)' )
end

Given /^I search for quizzes with name "([^"]+)"$/ do |needle|
  visit(quizzes_url)
  fill_in "Name", with: needle
  click_button "Search"
end

