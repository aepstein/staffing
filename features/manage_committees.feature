Feature: Manage committees
  In order to identify committees and associate them with positions and members
  As an administrator
  I want to create, modify, destroy, list, and show committees

  Scenario Outline: Test permissions for committees controller actions
    Given a committee exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new committee page
    Then I should <create>
    Given I post on the committees page
    Then I should <create>
    And I am on the edit page for the committee
    Then I should <update>
    Given I put on the page for the committee
    Then I should <update>
    Given I am on the page for the committee
    Then I should <show>
    Given I am on the committees page
    Then I should <show>
    Given I delete on the page for the committee
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" |

  Scenario: Register new committee
    Given I log in as the administrator
    And I am on the new committee page
    When I fill in "Name" with "Important Committee"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Committee was successfully created."
    And I should see "Name: Important Committee"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I fill in "Name" with "No Longer Important Committee"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Committee was successfully updated."
    And I should see "Name: No Longer Important Committee"
    And I should see "Welcome message"
    And I should see "Farewell message"

  Scenario: Delete committee
    Given a committee exists with name: "committee 4"
    And a committee exists with name: "committee 3"
    And a committee exists with name: "committee 2"
    And a committee exists with name: "committee 1"
    And I log in as the administrator
    When I delete the 3rd committee
    Then I should see the following committees:
      |Name       |
      |committee 1|
      |committee 2|
      |committee 4|

