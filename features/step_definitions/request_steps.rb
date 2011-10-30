Given /^#{capture_model} rejects #{capture_model} with authority: #{capture_model}, message: "(.+)"$/ do |who, what, authority, message|
  user = model who
  request = model what
  request.rejected_by_user = user
  request.assign_attributes( { :rejected_by_authority =>  model(authority),
    :rejection_comment => message }, { :without_protection => true } )
  request.reject!
end

