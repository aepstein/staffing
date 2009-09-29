Feature: Manage committees
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new committee
    Given I am on the new committee page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete committee
    Given the following committees:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd committee
    Then I should see the following committees:
      |Name|
      |name 1|
      |name 2|
      |name 4|
