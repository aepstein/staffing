Feature: Manage schedules
  In order to record schedules to associate with positions and committees and periods for meetings, motions, and memberships
  As an administrator
  I want to create, modify, list, show, and destroy schedules

Scenario Outline: Access control
  Given an authorization scenario of a schedule to which I have a <role> relationship
  Then I <show> see the schedule
  And I <create> create schedules
  And I <update> update the schedule
  And I <destroy> destroy the schedule
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

@javascript
Scenario: Create/edit a schedule
  Given I log in as the staff user
  When I create a schedule
  Then I should see the new schedule
  When I update the schedule
  Then I should see the edited schedule

Scenario: Search schedules
  Given I log in as the plain user
  And there are 4 schedules
  And I search for schedules with name "2"
  Then I should see the following schedules:
  | Schedule 2 |

Scenario: List/delete a schedule
  Given I log in as the admin user
  And there are 4 schedules
  And I "Destroy" the 3rd schedule
  Then I should see the following schedules:
  | Schedule 1 |
  | Schedule 2 |
  | Schedule 4 |

