Feature: Manage meeting templates
  In order to record meeting templates to associate with positions and committees and periods for meetings, motions, and memberships
  As an administrator
  I want to create, modify, list, show, and destroy meeting templates

Scenario Outline: Access control
  Given an authorization scenario of a meeting template to which I have a <role> relationship
  Then I <show> see the meeting template
  And I <create> create meeting templates
  And I <update> update the meeting template
  And I <destroy> destroy the meeting template
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

@javascript
Scenario: Create/edit a meeting template
  Given I log in as the staff user
  When I create a meeting template
  Then I should see the new meeting template
  When I update the meeting template
  Then I should see the edited meeting template

Scenario: Search meeting templates
  Given I log in as the plain user
  And there are 4 meeting templates
  And I search for meeting templates with name "2"
  Then I should see the following meeting templates:
  | Meeting Template 2 |

Scenario: List/delete a meeting template
  Given I log in as the admin user
  And there are 4 meeting templates
  And I "Destroy" the 3rd meeting template
  Then I should see the following meeting templates:
  | Meeting Template 1 |
  | Meeting Template 2 |
  | Meeting Template 4 |

