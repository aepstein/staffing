Given /^#{capture_model} is (divided|proposed|rejected|withdrawn|restarted)$/ do |motion, state|
  case state
  when 'divided'
    step "#{motion} is proposed"
    step "I log out"
    step "I log in as user: \"chair\""
    step "I am on the proposed motions page for the committee"
    step "I follow \"Divide\" within \"#motions\""
    step "I follow \"add dividing motion\""
    step %{I fill in "Name" with "Charter amendment"}
    step %{I fill in "Description" with "This is a *big* change."}
    step %{I fill in "Content" with "*Whereas* and *Resolved*"}
    step %{I press "Update Motion"}
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

