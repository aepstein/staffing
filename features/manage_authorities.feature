Feature: Manage authorities
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new authority
    Given I am on the new authority page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete authority
    Given the following authorities:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd authority
    Then I should see the following authorities:
      |Name|
      |name 1|
      |name 2|
      |name 4|
