Feature: Manage authorities
  In order to record authorities with power to staff positions
  As an administrator
  I want to create, modify, list, show, and destroy authorities

Scenario Outline: Access control
  Given an authorization scenario of an authority to which I have a <role> relationship
  Then I <show> see the authority
  And I <create> create authorities
  And I <update> update the authority
  And I <destroy> destroy the authority
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

Scenario: Create/edit an authority
  Given I log in as the staff user
  When I create an authority
  Then I should see the new authority
  When I update the authority
  Then I should see the edited authority

Scenario: List/delete an authority
  Given I log in as the admin user
  And there are 4 authorities
  And I "Destroy" the 3rd authority
  Then I should see the following authorities:
  | Authority 1 |
  | Authority 2 |
  | Authority 4 |

