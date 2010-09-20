Given /^#{capture_model} rejects #{capture_model} with authority: #{capture_model}, message: "(.+)"$/ do |who, what, authority, message|
  user = model who
  request = model what
  request.rejected_by_user = user
  request.reject( { :rejected_by_authority_id => model(authority).id, :rejection_comment => message } ).should be_true
end

