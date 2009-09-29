Feature: Manage users
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new user
    Given I am on the new user page
    When I fill in "First name" with "first_name 1"
    And I fill in "Middle name" with "middle_name 1"
    And I fill in "Last name" with "last_name 1"
    And I fill in "Email" with "email 1"
    And I fill in "Net" with "net_id 1"
    And I fill in "Status" with "status 1"
    And I press "Create"
    Then I should see "first_name 1"
    And I should see "middle_name 1"
    And I should see "last_name 1"
    And I should see "email 1"
    And I should see "net_id 1"
    And I should see "status 1"

  Scenario: Delete user
    Given the following users:
      |first_name|middle_name|last_name|email|net_id|status|
      |first_name 1|middle_name 1|last_name 1|email 1|net_id 1|status 1|
      |first_name 2|middle_name 2|last_name 2|email 2|net_id 2|status 2|
      |first_name 3|middle_name 3|last_name 3|email 3|net_id 3|status 3|
      |first_name 4|middle_name 4|last_name 4|email 4|net_id 4|status 4|
    When I delete the 3rd user
    Then I should see the following users:
      |First name|Middle name|Last name|Email|Net|Status|
      |first_name 1|middle_name 1|last_name 1|email 1|net_id 1|status 1|
      |first_name 2|middle_name 2|last_name 2|email 2|net_id 2|status 2|
      |first_name 4|middle_name 4|last_name 4|email 4|net_id 4|status 4|
