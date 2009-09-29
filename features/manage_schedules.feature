Feature: Manage schedules
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new schedule
    Given I am on the new schedule page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete schedule
    Given the following schedules:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd schedule
    Then I should see the following schedules:
      |Name|
      |name 1|
      |name 2|
      |name 4|
