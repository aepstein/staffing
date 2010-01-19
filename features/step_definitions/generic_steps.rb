Given /^(?:|I )(put|post|delete) on (.+)$/ do |method, page_name|
  visit path_to(page_name), method.to_sym
end

When /^I delete the (\d+)(?:st|nd|rd|th) #{capture_factory}$/ do |position, subject|
  visit polymorphic_path( [ subject.pluralize ] )
  within("table > tbody > tr:nth-child(#{position.to_i})") do
    click_link "Destroy"
  end
end

When /^I delete the (\d+)(?:st|nd|rd|th) #{capture_factory} for #{capture_model}$/ do |position, subject, context|
  visit polymorphic_path( [ model(context), subject.pluralize ] )
  within("table > tbody > tr:nth-child(#{position.to_i})") do
    click_link "Destroy"
  end
end

Then /^I should see the following #{capture_plural_factory}:$/ do |context, table|
  table.diff!(tableish('table > thead,tbody > tr', 'td,th'))
end

Given /^there are no (.+)s$/ do |type|
  type.classify.constantize.delete_all
end

Given /^the following (.+) records?:$/ do |factory, table|
  table.hashes.each do |record|
    Factory(factory, record)
  end
end

Given /^([0-9]+) (.+) records?$/ do |number, factory|
  number.to_i.times do
    Factory(factory)
  end
end

Given /^([0-9])+ seconds? elapses?$/ do |seconds|
  sleep seconds.to_i
end

Given /^the (.+) records? changes?$/ do |type|
  type.constantize.all.each { |o| o.touch }
end

# set up a many to many association
Given(/^#{capture_model} is (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association) << model(target)
end

Given(/^#{capture_model} is alone (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).delete_all
  model(owner).send(association) << model(target)
end

Then /^I should see the following entries in "(.+)":$/ do |table_id, expected_approvals_table|
  expected_approvals_table.diff!(table_at("##{table_id}").to_a)
end

