Feature: Manage committees
  In order to identify committees and associate them with positions and members
  As an administrator
  I want to create, modify, destroy, list, and show committees

  Scenario: Show available committees for current user
    Given a committee: "available" exists with name: "Available Committee", requestable: true
    And a committee: "unrequestable" exists with name: "Unrequestable Committee", requestable: false
    And a committee: "unavailable" exists with name: "Unavailable Committee", requestable: true
    And a committee: "no_positions" exists with name: "No Positions Committee", requestable: true
    And a position exists with name: "Available Position"
    And an enrollment exists with position: the position, committee: committee "available"
    And a position exists with name: "Unrequestable Position"
    And an enrollment exists with position: the position, committee: committee "unrequestable"
    And a position exists with name: "Unavailable Position", statuses_mask: 2
    And an enrollment exists with position: the position, committee: committee "unavailable"
    And a user: "owner" exists with net_id: "owner", password: "secret", first_name: "John", last_name: "Doe"
    And I log in as "owner" with password "secret"
    And I am on the requestable committees page for user: "owner"
    Then I should see "Requestable committees for John Doe"
    And I should see the following committees:
      |Name                |
      |Available Committee |
    And I should not see "Unrequestable Committee"
    And I should not see "Unavailable Committee"
    And I should not see "No Positions Committee"

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
    Given I am on the requestable committees page for user: "admin"
    Then I should <available>
    Given I am on the requestable committees page for user: "<user>"
    Then I should not see "not authorized"
    Examples:
      | user    | create                   | update                   | destroy                  | show                     | available                |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" | see "not authorized"     |

  Scenario: Register new committee
    Given I log in as the administrator
    And I am on the new committee page
    When I fill in "Name" with "Important Committee"
    And I choose "committee_requestable_true"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Committee was successfully created."
    And I should see "Name: Important Committee"
    And I should see "Requestable? Yes"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I fill in "Name" with "No Longer Important Committee"
    And I choose "committee_requestable_false"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Committee was successfully updated."
    And I should see "Name: No Longer Important Committee"
    And I should see "Requestable? No"
    And I should see "Welcome message"
    And I should see "Farewell message"

  Scenario: Delete committee
    Given a committee exists with name: "committee 4"
    And a committee exists with name: "committee 3"
    And a committee exists with name: "committee 2"
    And a committee exists with name: "committee 1"
    And I log in as the administrator
    When I am on the committees page
    And I fill in "Name" with "2"
    And I press "Search"
    Then I should see the following committees:
      |Name        |
      |committee 2 |
    When I delete the 3rd committee
    Then I should see the following committees:
      |Name       |
      |committee 1|
      |committee 2|
      |committee 4|

