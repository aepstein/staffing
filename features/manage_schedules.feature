Feature: Manage schedules
  In order to set different cycles on which positions are staffed
  As a system administrator
  I want to create, edit, view, and list schedules

  Background:
    And a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for schedules controller actions
    Given a schedule exists with name: "Focus"
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as user: "<user>"
    And I am on the page for the schedule
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the schedules page
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New schedule"
    Given I am on the new schedule page
    Then I should <create> authorized
    Given I post on the schedules page
    Then I should <create> authorized
    And I am on the edit page for the schedule
    Then I should <update> authorized
    Given I put on the page for the schedule
    Then I should <update> authorized
    Given I delete on the page for the schedule
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new schedule and edit
    Given I log in as user: "admin"
    And I am on the new schedule page
    When I fill in "Name" with "Even years"
    And I press "Create"
    Then I should see "Name: Even years"
    When I follow "Edit"
    And I fill in "Name" with "Odd years"
    And I press "Update"
    Then I should see "Name: Odd years"

  Scenario: Delete schedule
    Given a schedule exists with name: "schedule 4"
    And a schedule exists with name: "schedule 3"
    And a schedule exists with name: "schedule 2"
    And a schedule exists with name: "schedule 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd schedule
    Then I should see the following schedules:
      |Name      |
      |schedule 1|
      |schedule 2|
      |schedule 4|

