Feature: Manage committees
  In order to identify committees and associate them with positions and members
  As an administrator
  I want to create, modify, destroy, list, and show committees

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Show requestable committees for current user
    Given a position exists with requestable: <p_req>, requestable_by_committee: <p_req_c>, statuses_mask: <mask>
    And a committee exists with requestable: <c_req>
    And an enrollment exists with position: the position, committee: the committee
    And a user exists with statuses_mask: 1
    And I log in as the user
    Then I should see "You may browse <n_com> and <n_pos> for which you are eligible to request membership."
    Examples:
      | p_req | p_req_c | mask | c_req | n_pos       | n_com        |
      | true  | false   | 0    | false | 1 position  | 0 committees |
      | false | true    | 0    | false | 0 positions | 0 committees |
      | false | false   | 0    | false | 0 positions | 0 committees |
      | false | true    | 0    | true  | 0 positions | 1 committee  |
      | true  | true    | 0    | true  | 1 position  | 1 committee  |
      | false | true    | 2    | true  | 0 positions | 0 committees |
      | true  | false   | 2    | false | 0 positions | 0 committees |
      | false | true    | 3    | true  | 0 positions | 1 committee  |
      | true  | false   | 3    | false | 1 position  | 0 committees |

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
    And I fill in "Reject message" with "There were *no* slots."
    And I press "Create"
    Then I should see "Committee was successfully created."
    And I should see "Name: Important Committee"
    And I should see "Schedule: Annual"
    And I should see "Requestable? Yes"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    And I should see "There were no slots."
    When I follow "Edit"
    And I fill in "Name" with "No Longer Important Committee"
    And I choose "committee_requestable_false"
    And I select "Semester" from "Schedule"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I fill in "Reject message" with "There were *not enough* slots."
    And I press "Update"
    Then I should see "Committee was successfully updated."
    And I should see "Name: No Longer Important Committee"
    And I should see "Schedule: Semester"
    And I should see "Requestable? No"
    And I should see "Welcome message"
    And I should see "Farewell message"
    And I should see "There were not enough slots."

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

