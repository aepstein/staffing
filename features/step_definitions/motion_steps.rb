Given /^#{capture_model} is (proposed|rejected|withdrawn)$/ do |motion, state|
  case state
  when 'proposed'
    step "I log in as user: \"sponsor\""
    step "I follow \"Propose\" within \"#motions\""
  when 'rejected'
    step "#{motion} is proposed"
    step "I log out"
    step "I log in as user: \"chair\""
    step "I am on the proposed motions page for the committee"
    step "I follow \"Reject\" within \"#motions\""
  when 'withdrawn'
    step "#{motion} is proposed"
    step "I log out"
    step "I log in as user: \"sponsor\""
    step "I follow \"Withdraw\" within \"#motions\""
  end
end

