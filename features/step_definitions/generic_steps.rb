Given /^#{capture_model} is (?:in|one of|amongst) the (\w+) of #{capture_model}$/ do |target, association, owner|
  model(owner).send(association) << model(target)
end

