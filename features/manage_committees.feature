Feature: Manage committees
  In order to identify committees and associate them with positions and members
  As an administrator
  I want to create, modify, destroy, list, and show committees

  Background:
    Given a user: "admin" exists with admin: true

  Scenario: Show requestable committees for current user
    Given a committee: "beta" exists with name: "Beta Committee", requestable: true
    And a committee: "available" exists with name: "Available Committee", requestable: true
    And a committee: "unrequestable" exists with name: "Unrequestable Committee", requestable: false
    And a committee: "unavailable" exists with name: "Unavailable Committee", requestable: true
    And a committee: "no_positions" exists with name: "No Positions Committee", requestable: true
    And a position exists with name: "Available Position"
    And an enrollment exists with position: the position, committee: committee "available"
    And an enrollment exists with committee: committee "available"
    And an enrollment exists with committee: committee "beta"
    And a position exists with name: "Unrequestable Position"
    And an enrollment exists with position: the position, committee: committee "unrequestable"
    And a position exists with name: "Unavailable Position", statuses_mask: 2
    And an enrollment exists with position: the position, committee: committee "unavailable"
    And a user: "owner" exists with first_name: "John", last_name: "Doe"
    And I log in as user: "owner"
    Then I should see "You may browse 2 committees and 4 positions for which you are eligible to request membership."
    Given I am on the requestable committees page for user: "owner"
    Then I should see "Requestable committees for John Doe"
    And I should see the following committees:
      | Name                |
      | Available Committee |
      | Beta Committee      |
    And I should not see "Unrequestable Committee"
    And I should not see "Unavailable Committee"
    And I should not see "No Positions Committee"

  Scenario Outline: Test permissions for committees controller actions
    Given a committee exists with name: "Focus"
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the new committee page
    Then I should <create> authorized
    Given I post on the committees page
    Then I should <create> authorized
    And I am on the edit page for the committee
    Then I should <update> authorized
    Given I put on the page for the committee
    Then I should <update> authorized
    Given I am on the page for the committee
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the committees page
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New committee"
    Given I delete on the page for the committee
    Then I should <destroy> authorized
    Given I am on the requestable committees page for user: "admin"
    Then I should <available> authorized
    Given I am on the requestable committees page for user: "<user>"
    Then I should see authorized
    Examples:
      | user    | create  | update  | destroy | show | available |
      | admin   | see     | see     | see     | see  | see       |
      | regular | not see | not see | not see | see  | not see   |

  Scenario: Register new committee
    Given a schedule exists with name: "Annual"
    And a schedule exists with name: "Semester"
    And I log in as user: "admin"
    And I am on the new committee page
    When I fill in "Name" with "Important Committee"
    And I choose "committee_requestable_true"
    And I select "Annual" from "Schedule"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Committee was successfully created."
    And I should see "Name: Important Committee"
    And I should see "Schedule: Annual"
    And I should see "Requestable? Yes"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I fill in "Name" with "No Longer Important Committee"
    And I choose "committee_requestable_false"
    And I select "Semester" from "Schedule"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Committee was successfully updated."
    And I should see "Name: No Longer Important Committee"
    And I should see "Schedule: Semester"
    And I should see "Requestable? No"
    And I should see "Welcome message"
    And I should see "Farewell message"

  Scenario: Delete committee
    Given a committee exists with name: "committee 4"
    And a committee exists with name: "committee 3"
    And a committee exists with name: "committee 2"
    And a committee exists with name: "committee 1"
    And I log in as user: "admin"
    When I am on the committees page
    And I fill in "Name" with "2"
    And I press "Search"
    Then I should see the following committees:
      |Name        |
      |committee 2 |
    When I follow "Destroy" for the 3rd committee
    Then I should see the following committees:
      |Name       |
      |committee 1|
      |committee 2|
      |committee 4|

