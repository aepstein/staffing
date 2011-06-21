Then /^I debug$/ do
  breakpoint
  0
end

Then /^I pause$/ do
  STDIN.gets
  0
end

