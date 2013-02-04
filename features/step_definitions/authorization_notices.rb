Then /^I should( not)? be authorized$/ do |negate|
  if negate.blank?
    if page.has_selector?( '.alert' )
      find('.alert').should(
        have_no_text('You may not perform the requested action.') )
    end
  else
    URI.parse(current_url).path.should eql '/'
    find('.alert').should(
      have_text('You may not perform the requested action.') )
  end
end

