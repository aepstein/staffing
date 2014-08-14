Then /^I should( not)? be authorized$/ do |negate|
  if negate.blank?
    if page.has_selector?( '.alert' )
      expect( find('.alert') ).to(
        have_no_text('You may not perform the requested action.') )
    end
  else
    expect( URI.parse(current_url).path ).to eql '/'
    expect( find('.alert') ).to(
      have_text('You may not perform the requested action.') )
  end
end

