Feature: Manage users
  In order to record users to associate with positions and committees and periods for meetings, motions, and memberships
  As an administrator
  I want to create, modify, list, show, and destroy users

Scenario Outline: Access control
  Given an authorization scenario of a user to which I have a <role> relationship
  Then I <show> see the user
  And I <create> create users
  And I <update> update the user
  And I <destroy> destroy the user
  Examples:
    |role        |show   |create |update |destroy|
    |admin       |may    |may    |may    |may    |
    |staff       |may    |may    |may    |may not|
    |authority   |may    |may not|may not|may not|
    |authority_ro|may    |may not|may not|may not|
    |owner       |may    |may not|may    |may not|
    |plain       |may not|may not|may not|may not|

Scenario Outline: Create/edit a user
  Given I log in as the <role> user
  When I create a user as <role>
  Then I should see the new user as <role>
  When I update the user as <role>
  Then I should see the edited user as <role>
  Examples:
    |role |
    |admin|
    |staff|

Scenario: Edit a user as owner
  Given an authorization scenario of a user to which I have an owner relationship
  When I update the user as owner
  Then I should see the edited user as owner

Scenario: Search users
  Given I log in as the staff user
  And there are 4 users
  # contains first name
  When I search for users with name "35"
  Then I should see the following users:
    | User 13, Sequenced35 |
  # contains last name
  When I search for users with name "13"
  Then I should see the following users:
    | User 13, Sequenced35 |
  # contains netid
  When I search for users with name "24"
  Then I should see the following users:
    | User 13, Sequenced35 |

Scenario: List/delete a user
  Given I log in as the admin user
  And there are 4 users
  And I "Destroy" the 4th user
  Then I should see the following users:
    | Administrator, Senior |
    | User 11, Sequenced33  |
    | User 12, Sequenced34  |
    | User 14, Sequenced36  |
@wip
Scenario Outline: Set user empl_ids in bulk
  Given I log in as the staff user
  When I set empl_ids in bulk via <method>
  Then I should see empl_ids set
  Examples:
    |method    |
    |text      |
    |attachment|

