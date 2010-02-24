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

  Scenario Outline: Test permissions for positions controller actions
    Given a position exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new position page
    Then I should <create>
    Given I post on the positions page
    Then I should <create>
    And I am on the edit page for the position
    Then I should <update>
    Given I put on the page for the position
    Then I should <update>
    Given I am on the page for the position
    Then I should <show>
    Given I am on the positions page
    Then I should <show>
    Given I delete on the page for the position
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" |

  Scenario: Register new position and edit
    Given I log in as the administrator
    And I am on the new position page
    When I select "Student Assembly" from "Authority"
    And I select "Student Assembly Generic Questionnaire" from "Quiz"
    And I select "Annual Academic" from "Schedule"
    And I choose "position_requestable_true"
    And I fill in "Slots" with "1"
    And I check "Undergrad"
    And I fill in "Name" with "Popular Committee Member"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Position was successfully created."
    And I should see "Authority: Student Assembly"
    And I should see "Quiz: Student Assembly Generic Questionnaire"
    And I should see "Schedule: Annual Academic"
    And I should see "Requestable? Yes"
    And I should see "Slots: 1"
    And I should see "undergrad"
    And I should see "Name: Popular Committee Member"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I select "Graduate and Professional Student Assembly" from "Authority"
    And I select "Graduate and Professional Student Assembly Generic Questionnaire" from "Quiz"
    And I select "Annual Academic - Even Two Year" from "Schedule"
    And I choose "position_requestable_false"
    And I fill in "Slots" with "2"
    And I fill in "Name" with "Super-Popular Committee Member"
    And I uncheck "Undergrad"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Position was successfully updated."
    And I should see "Authority: Graduate and Professional Student Assembly"
    And I should see "Quiz: Graduate and Professional Student Assembly Generic Questionnaire"
    And I should see "Schedule: Annual Academic - Even Two Year"
    And I should see "Requestable? No"
    And I should see "Slots: 2"
    And I should see "No status restrictions."
    And I should see "Name: Super-Popular Committee Member"
    And I should see "Welcome message"
    And I should see "Farewell message"

  Scenario: Search and delete positions
    Given a position exists with name: "position 4"
    And a position exists with name: "position 3"
    And a position exists with name: "position 2"
    And a position exists with name: "position 1"
    And I log in as the administrator
    And I am on the positions page
    And fill in "Name" with "2"
    And I press "Search"
    Then I should see the following positions:
      |Name       |
      |position 2 |
    When I delete the 3rd position
    Then I should see the following positions:
      |Name      |
      |position 1|
      |position 2|
      |position 4|

