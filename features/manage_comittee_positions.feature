Feature: Manage committee positions
  In order to identify positions associated with a committee through enrollments
  As a user interested in managing committee structures
  I want to list committee positions

  Background:
    Given a position: "in" exists with name: "Included position"
    And a position: "out" exists with name: "Excluded position"
    And a position: "other" exists with name: "Other position"
    And a committee: "focus" exists with name: "Focus Committee"
    And a committee: "other" exists with name: "Other Committee"
    And an enrollment exists with position: position "in", committee: committee "focus"
    And an enrollment exists with position: position "other", committee: committee "other"

  Scenario: List only included position
    Given I log in as the administrator
    And I am on the positions page for committee: "focus"
    Then I should see the following positions:
      |Name              |
      |Included position |
    And I should not see "Excluded position"
    And I should not see "Other position"

