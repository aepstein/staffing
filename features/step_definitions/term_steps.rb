Given /^the following terms:$/ do |terms|
  Term.create!(terms.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) term$/ do |pos|
  visit terms_url
  within("table > tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following terms:$/ do |expected_terms_table|
  expected_terms_table.diff!(table_at('table').to_a)
end
