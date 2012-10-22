Feature: Manage committees
  In order to record committees to associate with committees and users
  As an administrator
  I want to create, modify, list, show, and destroy committees

Scenario Outline: Access control
  Given an authorization scenario of a committee to which I have a <role> relationship
  Then I <show> see the committee
  And I <create> create committees
  And I <update> update the committee
  And I <destroy> destroy the committee
  Examples:
    |role |show|create |update |destroy|
    |admin|may |may    |may    |may    |
    |staff|may |may    |may    |may not|
    |plain|may |may not|may not|may not|

@javascript
Scenario: Create/edit a committee
  Given I log in as the staff user
  When I create an committee
  Then I should see the new committee
  When I update the committee
  Then I should see the edited committee

Scenario: Search committees
  Given I log in as the plain user
  And there are 4 committees
  And I search for committees with name "2"
  Then I should see the following committees:
  | Committee 2 |

Scenario: List/delete a committee
  Given I log in as the admin user
  And there are 4 committees
  And I "Destroy" the 3rd committee
  Then I should see the following committees:
  | Committee 1 |
  | Committee 2 |
  | Committee 4 |

Scenario Outline: List requestable committees
  Given I log in as the plain user
  And I have a <user> status
  And the committee is requestable to <committee> status
  Then I <may> request membership in the committee
  Examples:
    |user     |committee|may    |
    |undergrad|student  |may    |
    |undergrad|grad     |may not|
    |undergrad|any      |may    |
    |undergrad|no       |may not|
    |no       |no       |may not|

Scenario Outline: Reports for committee
  Given a report scenario of a committee to which I have a <tense> <role> relationship
  When I download the <type> report
  Examples:
    |tense  |role |type       |
    |current|staff|members csv|
    |current|staff|members pdf|
    |current|staff|tents pdf  |
    |current|staff|emplid csv |

