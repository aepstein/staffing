Feature: Manage requests
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new request
    Given I am on the new request page
    When I fill in "Term" with "term 1"
    And I fill in "Position" with "position 1"
    And I fill in "User" with "user 1"
    And I fill in "State" with "state 1"
    And I press "Create"
    Then I should see "term 1"
    And I should see "position 1"
    And I should see "user 1"
    And I should see "state 1"

  Scenario: Delete request
    Given the following requests:
      |term|position|user|state|
      |term 1|position 1|user 1|state 1|
      |term 2|position 2|user 2|state 2|
      |term 3|position 3|user 3|state 3|
      |term 4|position 4|user 4|state 4|
    When I delete the 3rd request
    Then I should see the following requests:
      |Term|Position|User|State|
      |term 1|position 1|user 1|state 1|
      |term 2|position 2|user 2|state 2|
      |term 4|position 4|user 4|state 4|
