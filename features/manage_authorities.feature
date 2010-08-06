Feature: Manage authorities
  In order to identify and enable groups to manage committee membership
  As an administrator
  I want to create, edit, list, delete, and show authorities

  Scenario Outline: Test permissions for authorities controller actions
    Given an authority: "basic" exists
    And a user: "admin" exists with admin: true
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the new authority page
    Then I should <create> authorized
    Given I post on the authorities page
    Then I should <create> authorized
    And I am on the edit page for authority: "basic"
    Then I should <update> authorized
    Given I put on the page for authority: "basic"
    Then I should <update> authorized
    Given I am on the page for authority: "basic"
    Then I should <show> authorized
    Given I delete on the page for authority: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new authority and edit
    Given a committee exists with name: "First committee"
    And a committee exists with name: "Second committee"
    And I log in as the administrator
    And I am on the new authority page
    When I fill in "Name" with "Supreme Authority"
    And I fill in "Committee" with "First committee"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Authority was successfully created."
    And I should see "Name: Supreme Authority"
    And I should see "Committee: First committee"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I fill in "Name" with "Subordinate Authority"
    And I fill in "Committee" with "Second committee"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Authority was successfully updated."
    And I should see "Name: Subordinate Authority"
    And I should see "Committee: Second committee"
    And I should see "Welcome message"
    And I should see "Farewell message"

  Scenario: Delete authority
    Given an authority exists with name: "authority 4"
    And an authority exists with name: "authority 3"
    And an authority exists with name: "authority 2"
    And an authority exists with name: "authority 1"
    And I log in as the administrator
    When I delete the 3rd authority
    Then I should see the following authorities:
      |Name       |
      |authority 1|
      |authority 2|
      |authority 4|

