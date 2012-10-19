Feature: Manage brands
  In order to record brands to associate with committees and users
  As an administrator
  I want to create, modify, list, show, and destroy brands

Scenario Outline: Access control
  Given an authorization scenario of a brand to which I have a <role> relationship
  Then I <show> see the brand
  And I <create> create brands
  And I <update> update the brand
  And I <destroy> destroy the brand
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

Scenario: Create/edit a brand
  Given I log in as the staff user
  When I create an brand
  Then I should see the new brand
  When I update the brand
  Then I should see the edited brand

Scenario: List/delete a brand
  Given I log in as the admin user
  And there are 4 brands
  And I "Destroy" the 3rd brand
  Then I should see the following brands:
  | Brand 1 |
  | Brand 2 |
  | Brand 4 |

