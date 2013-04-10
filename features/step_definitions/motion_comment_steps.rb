Given /^a comment for the motion exists to which I have a (admin|staff|commenter|plain) relationship$/ do |relation|
  @motion_comment = case relation
  when 'commenter'
    create(:motion_comment, motion: @motion, user: @current_user)
  else
    create(:motion_comment, motion: @motion)
  end
end

Given /^the motion is (never|no longer|still) open for comment$/ do |open|
  case open
  when 'never'
    @motion.update_column :comment_until, nil
  when 'still'
    @motion.update_column( :comment_until, ( Time.zone.now + 1.day ) )
  else
    @motion.update_column( :comment_until, ( Time.zone.now - 1.hour ) )
  end
end

Then /^I may( not)? create comments for the motion$/ do |negate|
  Capybara.current_session.driver.submit :post, motion_motion_comments_url(@motion), {}
  step %{I should#{negate} be authorized}
  visit(new_motion_motion_comment_url(@motion))
  step %{I should#{negate} be authorized}
  visit(motion_url(@motion))
  if negate.blank?
    page.should have_text('Add comment')
  else
    page.should have_no_text('Add comment')
  end
end

Then /^I may( not)? update the motion comment$/ do |negate|
  Capybara.current_session.driver.submit :put, motion_comment_url(@motion_comment), {}
  step %{I should#{negate} be authorized}
  visit(edit_motion_comment_url(@motion_comment))
  step %{I should#{negate} be authorized}
  visit(motion_url(@motion))
  if negate.blank?
    within("#motion-comment-#{@motion_comment.id}") { page.should have_text('Edit') }
  else
    if page.has_selector?( "#motion-comment-#{@motion_comment.id}" )
      within("#motion-comment-#{@motion_comment.id}") { page.should have_no_text('Edit') }
    end
  end
end

Then /^I may( not)? destroy the motion comment$/ do |negate|
  visit(motion_url(@motion))
  if negate.blank?
    within("#motion-comment-#{@motion_comment.id}") { page.should have_text('Destroy') }
  else
    page.should have_no_text('Destroy')
  end
  Capybara.current_session.driver.submit :delete, motion_comment_url(@motion_comment), {}
  step %{I should#{negate} be authorized}
end

Then /^I may( not)? see the motion comment$/ do |negate|
  visit(motion_url(@motion))
  if negate.blank?
    page.should have_selector( "#motion-comment-#{@motion_comment.id}" )
  else
    page.should have_no_selector( "#motion-comment-#{@motion_comment.id}" )
  end
end

