Given /^#{capture_model} is( not)? interested in renewal$/ do |membership, negate|
  m = model(membership)
  m.update_column :renew_until, ( negate ? nil : ( m.ends_at + 2.years ) )
end

Given /^#{capture_model} is( not)? declined renewal$/ do |membership, negate|
  m = model(membership)
  m.update_column :declined_at, ( negate ? nil : Time.zone.now )
end

Given /^#{capture_model} has( not)? confirmed renewal preference$/ do |membership, negate|
  m = model(membership)
  m.update_column :renewal_confirmed_at, ( negate ? nil : ( Time.zone.now ) )
end

