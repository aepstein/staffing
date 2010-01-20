Feature: Manage schedules
  In order to set different cycles on which positions are staffed
  As a system administrator
  I want to create, edit, view, and list schedules

  Scenario Outline: Test permissions for schedules controller actions
    Given a schedule exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new schedule page
    Then I should <create>
    Given I post on the schedules page
    Then I should <create>
    And I am on the edit page for the schedule
    Then I should <update>
    Given I put on the page for the schedule
    Then I should <update>
    Given I am on the page for the schedule
    Then I should <show>
    Given I am on the schedules page
    Then I should <show>
    Given I delete on the page for the schedule
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" |

  Scenario: Register new schedule and edit
    Given I log in as the administrator
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
    And I log in as the administrator
    When I delete the 3rd schedule
    Then I should see the following schedules:
      |Name      |
      |schedule 1|
      |schedule 2|
      |schedule 4|

