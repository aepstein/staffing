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

# Adds support for validates_attachment_content_type. Without the mime-type getting
# passed to attach_file() you will get a "Photo file is not one of the allowed file types."
# error message
When /^(?:|I )attach a file of type "([^\"]*)" and (\d+) (bytes?|kilobytes?|megabytes?) to "([^\"]*)"$/ do |type, size, unit, field|
  file = Tempfile.new('resume.pdf')
  $temporary_files << file
  size.to_i.send( unit.to_sym ).times { file << 'a' }
  ActionController::TestUploadedFile.new(file.path,type)

  attach_file(field, file.path, type)
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

Then /^I should see the following entries in "(.+)":$/ do |table_id, table|
  table.diff!(tableish("##{table_id} > thead,tbody > tr", 'td,th'))
end

