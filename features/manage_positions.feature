@stub
Feature: Manage positions
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new position
    Given I am on the new position page
    When I fill in "Authority" with "authority 1"
    And I fill in "Committee" with "committee 1"
    And I fill in "Quiz" with "quiz 1"
    And I fill in "Schedule" with "schedule 1"
    And I fill in "Slots" with "slots 1"
    And I fill in "Voting" with "false"
    And I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "authority 1"
    And I should see "committee 1"
    And I should see "quiz 1"
    And I should see "schedule 1"
    And I should see "slots 1"
    And I should see "false"
    And I should see "name 1"

  Scenario: Delete position
    Given the following positions:
      |authority|committee|quiz|schedule|slots|voting|name|
      |authority 1|committee 1|quiz 1|schedule 1|slots 1|false|name 1|
      |authority 2|committee 2|quiz 2|schedule 2|slots 2|true|name 2|
      |authority 3|committee 3|quiz 3|schedule 3|slots 3|false|name 3|
      |authority 4|committee 4|quiz 4|schedule 4|slots 4|true|name 4|
    When I delete the 3rd position
    Then I should see the following positions:
      |Authority|Committee|Quiz|Schedule|Slots|Voting|Name|
      |authority 1|committee 1|quiz 1|schedule 1|slots 1|false|name 1|
      |authority 2|committee 2|quiz 2|schedule 2|slots 2|true|name 2|
      |authority 4|committee 4|quiz 4|schedule 4|slots 4|true|name 4|

