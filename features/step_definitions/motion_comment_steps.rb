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
  Capybara.current_session.driver.submit :post,
    motion_motion_comments_url(@motion),
    { "motion_comment" => { "comment" => "" } }
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
  Capybara.current_session.driver.submit :put,
    motion_comment_url(@motion_comment),
    { "motion_comment" => { "comment" => "" } }
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


When /^I create a motion comment$/ do
  step %{a current published, proposed motion exists of sponsored origin to which I have a plain relationship}
  step %{the motion is still open for comment}
  visit new_motion_motion_comment_path( @motion )
  fill_in "Comment", with: "This is my comment."
  click_link "Add Attachment"
  within_fieldset("New Attachment") do
    attach_file 'Attachment document', File.expand_path('spec/assets/empl_ids.csv')
    fill_in 'Attachment description', with: 'Sample employee ids'
  end
  click_button "Create"
end

Then /^I should see the new motion comment$/ do
  within( ".alert" ) { page.should have_text( "Motion comment created." ) }
  @motion_comment = @motion.motion_comments.last
  within("#motion-comment-#{@motion_comment.id}") do
    page.should have_text "This is my comment."
  end
end

When /^I update the motion comment$/ do
  visit edit_motion_comment_path( @motion_comment )
  fill_in "Comment", with: "Some other *comment*."
  click_link "Remove Attachment"
  click_button "Update"
end

Then /^I should see the edited motion comment$/ do
  within( ".alert" ) { page.should have_text( "Motion comment updated." ) }
  visit motion_comment_path( @motion_comment )
  page.should have_text "Some other comment."
  @motion_comment.reload
  @motion_comment.attachments.count.should eql 0
end

Given /^the motion has( no)? comments$/ do |negate|
  if negate.blank?
    @motion.update_column( :comment_until, Time.zone.now + 1.week )
    create(:motion_comment, motion: @motion)
  end
end

When /^I download the comments pdf report for the motion$/ do
  VectorUploader.enable_processing = true
  create :brand
  VectorUploader.enable_processing = false
  visit motion_motion_comments_url( @motion, format: :pdf )
end

Then /^I should( not)? see the comments report$/ do |negate|
#  save_and_open_page
  if negate.blank?
    page.response_headers["Content-Disposition"].should eql "inline; filename=\"comments-#{@motion.to_s :file}.pdf\""
  else
    within(".alert") { page.should have_text 'No comments provided for the motion.' }
  end
end

