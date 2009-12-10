@stub
Feature: Manage answers
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new answer
    Given I am on the new answer page
    When I fill in "Question" with "question 1"
    And I fill in "Request" with "request 1"
    And I fill in "Content" with "content 1"
    And I press "Create"
    Then I should see "question 1"
    And I should see "request 1"
    And I should see "content 1"

  Scenario: Delete answer
    Given the following answers:
      |question|request|content|
      |question 1|request 1|content 1|
      |question 2|request 2|content 2|
      |question 3|request 3|content 3|
      |question 4|request 4|content 4|
    When I delete the 3rd answer
    Then I should see the following answers:
      |Question|Request|Content|
      |question 1|request 1|content 1|
      |question 2|request 2|content 2|
      |question 4|request 4|content 4|

