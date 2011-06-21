Given /^#{capture_model} is( not)? interested in renewal$/ do |membership, negate|
  m = model(membership)
  m.update_attribute :renew_until, ( negate ? nil : ( m.ends_at + 2.years ) )
end

Given /^#{capture_model} has( not)? confirmed renewal preference$/ do |membership, negate|
  m = model(membership)
  m.update_attribute :renewal_confirmed_at, ( negate ? nil : ( Time.zone.now ) )
end

