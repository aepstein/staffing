Given /^#{capture_model} exists? (before|after) #{capture_model}(?: with #{capture_fields})?$/ do |name, position, parent, attributes|
  p = model(parent)
  if position == 'after'
    a = "starts_at: \"#{(p.ends_at + 1.day).to_s :rfc822}\", "
    a << "ends_at: \"#{(p.ends_at + 1.year).to_s :rfc822}\""
  else
    a = "ends_at: \"#{(p.starts_at - 1.day).to_s :rfc822}\", "
    a << "starts_at: \"#{(p.starts_at - 1.year).to_s :rfc822}\""
  end
  create_model( name, ( attributes.blank? ? a : "#{attributes}, #{a}" ) )
end

Given(/^#{capture_model} (?:has|have) #{capture_fields}$/) do |name, fields|
  subject = model(name)
  parse_fields(fields).each { |field, value| subject.send( "#{field}=", value ) }
  subject.save!
end

Given /^(?:|I )(put|post|delete) on (.+)$/ do |method, page_name|
#  visit path_to(page_name), method.to_sym
  # TODO this only works with the rack driver
  Capybara.current_session.driver.process method.to_sym, path_to(page_name), {}
end

Then /^I should see authorized$/ do
  Then %{I should not see "You are not allowed to perform the requested action."}
end

Then /^I should not see authorized$/ do
  Then %{I should see "You are not allowed to perform the requested action."}
end

When /^I fill in "(\w+)" with #{capture_relative_date}$/ do |field, date|
  When %{I fill in "#{field}" with "#{relative_date(date).to_s :rfc822}"}
end

Then /^I should( not)? see #{capture_relative_date}(.*)$/ do |negate, date, suffix|
  Then %{I should#{negate} see "#{relative_date(date).to_s :rfc822}"#{suffix}}
end

Then /^the "([^\"]+)" field should( not)? contain #{capture_relative_date}$/ do |field, negate, date|
  Then %{the "#{field}" field should#{negate} contain "#{relative_date(date).to_s :rfc822}"}
end

# Adds support for validates_attachment_content_type. Without the mime-type get
# passed to attach_file() you will get a "Photo file is not one of the allowed
# error message
When /^(?:|I )attach a file of type "([^\"]*)" and (\d+) (bytes?|kilobytes?|megabytes?) to "([^\"]*)"$/ do |type, size, unit, field|
  file = Tempfile.new('resume.pdf')
  $temporary_files ||= Array.new
  $temporary_files << file
  size.to_i.send( unit.to_sym ).times { file << 'a' }
#  fixture_file_upload file.path, type

#  attach_file(field, file.path, type)
  attach_file field, file.path
end

When /^I follow "(.+)" for the (\d+)(?:st|nd|rd|th) #{capture_factory}(?: for #{capture_model})?$/ do |link, position, subject, context|
  visit polymorphic_path( [ ( context.blank? ? nil : model(context) ), subject.pluralize ] )
  within("table > tbody > tr:nth-child(#{position.to_i})") do
    click_link "#{link}"
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

# assert model is in another model's has_many assoc
Then(/^#{capture_model} should be (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).should include(model(target))
end

# assert model is NOT in another model's has_many assoc
Then(/^#{capture_model} should not be (?:in|one of|amongst) the (\w+) of #{capture_model}$/) do |target, association, owner|
  model(owner).send(association).should_not include(model(target))
end

Then /^I should see the following entries in "(.+)":$/ do |table_id, table|
  table.diff!(tableish("##{table_id} > thead,tbody > tr", 'td,th'))
end

Given /^an? ([a-z\s_]+) email is sent for #{capture_model}$/ do |notice, context|
  notice[" "]= "_" if notice[" "]
  "#{model(context).class.to_s}Mailer".constantize.send( notice, model(context) ).deliver
end

Then /^(?:I|they) should not see "([^"]*?)" in the email body$/ do |text|
  current_email.default_part_body.to_s.should_not include(text)
end

Then /^(?:I|they) should not see "([^"]*?)" in the email html part body$/ do |text|
  current_email.html_part.body.to_s.should_not include(text)
end

Then /^(?:I|they) should not see "([^"]*?)" in the email text part body$/ do |text|
  current_email.text_part.body.to_s.should_not include(text)
end

Then /^(?:I|they) should not see "([^\"]*)" in the email "([^"]*?)" header$/ do |text, name|
  current_email.should_not have_header(name, text)
end


Then /^(?:|I) should see a field labeled "(.+)"$/ do |text|
  within('form').should contain(text)
end

Then /^(?:|I) should not see a field labeled "(.+)"$/ do |text|
  within('form').should_not contain(text)
end

