Given /^the following answers:$/ do |answers|
  Answer.create!(answers.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) answer$/ do |pos|
  visit answers_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following answers:$/ do |expected_answers_table|
  expected_answers_table.diff!(table_at('table').to_a)
end
