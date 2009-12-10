@stub
Feature: Manage qualifications
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new qualification
    Given I am on the new qualification page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete qualification
    Given the following qualifications:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd qualification
    Then I should see the following qualifications:
      |Name|
      |name 1|
      |name 2|
      |name 4|

