Feature: Manage committees
  In order to identify committees and associate them with positions and members
  As an administrator
  I want to create, modify, destroy, list, and show committees

  Scenario: Register new committee
    Given I am on the new committee page
    When I fill in "Name" with "Important Committee"
    And I press "Create"
    Then I should see "Committee was successfully created."
    And I should see "Name: Important Committee"
    When I follow "Edit"
    And I fill in "Name" with "No Longer Important Committee"
    And I press "Update"
    Then I should see "Committee was successfully updated."
    And I should see "Name: No Longer Important Committee"

  Scenario: Delete committee
    Given a committee exists with name: "committee 4"
    And a committee exists with name: "committee 3"
    And a committee exists with name: "committee 2"
    And a committee exists with name: "committee 1"
    When I delete the 3rd committee
    Then I should see the following committees:
      |Name       |
      |committee 1|
      |committee 2|
      |committee 4|

