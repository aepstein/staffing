Feature: Manage schedules
  In order to set different cycles on which positions are staffed
  As a system administrator
  I want to create, edit, view, and list schedules

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
    When I delete the 3rd schedule
    Then I should see the following schedules:
      |Name      |
      |schedule 1|
      |schedule 2|
      |schedule 4|

