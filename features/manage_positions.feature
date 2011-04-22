Feature: Manage positions
  In order to represent positions in which people may be staffed
  As an administrator
  I want to create, modify, list, show, and delete positions

  Background:
    Given an authority: "sa" exists with name: "Student Assembly"
    And an authority: "gpsa" exists with name: "Graduate and Professional Student Assembly"
    And a quiz: "sa" exists with name: "Student Assembly Generic Questionnaire"
    And a quiz: "gpsa" exists with name: "Graduate and Professional Student Assembly Generic Questionnaire"
    And a schedule: "annual" exists with name: "Annual Academic"
    And a schedule: "biannual" exists with name: "Annual Academic - Even Two Year"
    And a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for positions controller actions
    Given a position exists with name: "Focus"
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the position
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the positions page
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New position"
    Given I am on the new position page
    Then I should <create> authorized
    Given I post on the positions page
    Then I should <create> authorized
    And I am on the edit page for the position
    Then I should <update> authorized
    Given I put on the page for the position
    Then I should <update> authorized
    Given I delete on the page for the position
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new position and edit
    Given I log in as user: "admin"
    And I am on the new position page
    When I select "Student Assembly" from "Authority"
    And I select "Student Assembly Generic Questionnaire" from "Quiz"
    And I select "Annual Academic" from "Schedule"
    And I choose "position_requestable_true"
    And I choose "position_renewable_true"
    And I choose "position_requestable_by_committee_true"
    And I choose "position_notifiable_true"
    And I choose "position_designable_true"
    And I choose "position_active_true"
    And I fill in "Slots" with "1"
    And I check "undergrad"
    And I fill in "Name" with "Popular Committee Member"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I fill in "Reject message" with "There were *no* slots."
    And I press "Create"
    Then I should see "Position was successfully created."
    And I should see "Authority: Student Assembly"
    And I should see "Quiz: Student Assembly Generic Questionnaire"
    And I should see "Schedule: Annual Academic"
    And I should see "Requestable? Yes"
    And I should see "Renewable? Yes"
    And I should see "Requestable by committee? Yes"
    And I should see "Notifiable? Yes"
    And I should see "Designable? Yes"
    And I should see "Active? Yes"
    And I should see "Slots: 1"
    And I should see "undergrad"
    And I should see "Name: Popular Committee Member"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    And I should see "There were no slots."
    When I follow "Edit"
    And I select "Graduate and Professional Student Assembly" from "Authority"
    And I select "Graduate and Professional Student Assembly Generic Questionnaire" from "Quiz"
    And I select "Annual Academic - Even Two Year" from "Schedule"
    And I choose "position_requestable_false"
    And I choose "position_renewable_false"
    And I choose "position_requestable_by_committee_false"
    And I choose "position_notifiable_false"
    And I choose "position_designable_false"
    And I choose "position_active_false"
    And I fill in "Slots" with "2"
    And I fill in "Name" with "Super-Popular Committee Member"
    And I uncheck "undergrad"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I fill in "Reject message" with "There were *not enough* slots."
    And I press "Update"
    Then I should see "Position was successfully updated."
    And I should see "Authority: Graduate and Professional Student Assembly"
    And I should see "Quiz: Graduate and Professional Student Assembly Generic Questionnaire"
    And I should see "Schedule: Annual Academic - Even Two Year"
    And I should see "Requestable? No"
    And I should see "Renewable? No"
    And I should see "Requestable by committee? No"
    And I should see "Notifiable? No"
    And I should see "Designable? No"
    And I should see "Active? No"
    And I should see "Slots: 2"
    And I should see "No status restrictions."
    And I should see "Name: Super-Popular Committee Member"
    And I should see "Welcome message"
    And I should see "Farewell message"
    And I should see "There were not enough slots."

  Scenario: Search and delete positions
    Given a position exists with name: "position 4"
    And a position exists with name: "position 3"
    And a position exists with name: "position 2"
    And a position exists with name: "position 1"
    And I log in as user: "admin"
    And I am on the positions page
    And fill in "Name" with "2"
    And I press "Search"
    Then I should see the following positions:
      |Name       |
      |position 2 |
    When I follow "Destroy" for the 3rd position
    Then I should see the following positions:
      |Name      |
      |position 1|
      |position 2|
      |position 4|

