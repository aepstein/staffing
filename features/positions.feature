Feature: Manage positions
  In order to record positions to associate with positions and users
  As an administrator
  I want to create, modify, list, show, and destroy positions

Scenario Outline: Access control
  Given an authorization scenario of a position to which I have a <role> relationship
  Then I <show> see the position
  And I <create> create positions
  And I <update> update the position
  And I <destroy> destroy the position
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

@javascript
Scenario: Create/edit a position
  Given I log in as the staff user
  When I create a position
  Then I should see the new position
  When I update the position
  Then I should see the edited position

Scenario: Search positions
  Given I log in as the plain user
  And there are 4 positions
  And I search for positions with name "2"
  Then I should see the following positions:
  | Position 2 |

Scenario: List/delete a position
  Given I log in as the admin user
  And there are 4 positions
  And I "Destroy" the 3rd position
  Then I should see the following positions:
  | Position 1 |
  | Position 2 |
  | Position 4 |

