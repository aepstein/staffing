@stub
Feature: Manage questions
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new question
    Given I am on the new question page
    When I fill in "Name" with "name 1"
    And I fill in "Content" with "content 1"
    And I press "Create"
    Then I should see "name 1"
    And I should see "content 1"

  Scenario: Delete question
    Given the following questions:
      |name|content|
      |name 1|content 1|
      |name 2|content 2|
      |name 3|content 3|
      |name 4|content 4|
    When I delete the 3rd question
    Then I should see the following questions:
      |Name|Content|
      |name 1|content 1|
      |name 2|content 2|
      |name 4|content 4|

