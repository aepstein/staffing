Given /^#{capture_model} rejects #{capture_model} with authority: #{capture_model}, message: "(.+)"$/ do |who, what, authority, message|
  user = model who
  request = model what
  request.rejected_by_user = user
  request.accessible = Request::REJECTABLE_ATTRIBUTES
  request.attributes = { :rejected_by_authority_id => model(authority).id,
    :rejection_comment => message }
  request.reject!
end

