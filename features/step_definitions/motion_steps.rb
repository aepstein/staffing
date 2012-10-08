Given /^#{capture_model} is (divided|proposed|rejected|withdrawn|restarted)$/ do |motion, state|
  case state
  when 'divided'
    step "#{motion} is proposed"
    step "I log out"
    step "I log in as user: \"chair\""
    step "I am on the proposed motions page for the committee"
    step "I follow \"Divide\" within \"#motions\""
    # fill in the divide form & submit
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
  when 'restarted'
    step "I log in as user: \"sponsor\""
    step "I follow \"Restart\" within \"#motions\""
  end
end

