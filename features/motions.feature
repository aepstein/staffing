Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to create, modify, list, show, and destroy motions

Scenario Outline: Access control
  Given an authorization scenario of <pub>published, <status> motion of <origin> origin to which I have a <tense> <relation> relationship
  And I <show> see the motion
  And I <create> create motions for the committee
  And I <update> update the motion
  And I <destroy> destroy the motion
  Examples:
    |relation |tense  |origin   |pub|status  |show   |create |update |destroy|
    |admin    |current|sponsored|un |started |may    |may    |may    |may    |
    |admin    |current|sponsored|   |proposed|may    |may    |may    |may    |
    |admin    |past   |sponsored|un |started |may    |may    |may    |may    |
    |admin    |future |sponsored|un |started |may    |may    |may    |may    |
    |staff    |current|sponsored|un |started |may    |may    |may    |may not|
    |staff    |past   |sponsored|un |started |may    |may    |may    |may not|
    |staff    |future |sponsored|un |started |may    |may    |may    |may not|
    |vicechair|current|referred |un |started |may    |may    |may    |may not|
    |vicechair|current|sponsored|un |started |may not|may    |may not|may not|
    |vicechair|past   |sponsored|un |started |may not|may not|may not|may not|
    |nonvoter |current|sponsored|un |started |may not|may not|may not|may not|
    |sponsor  |current|referred |un |started |may    |may    |may    |may not|
    |sponsor  |current|sponsored|un |started |may    |may    |may    |may not|
    |sponsor  |current|sponsored|un |proposed|may    |may not|may not|may not|
    |sponsor  |past   |sponsored|un |started |may    |may not|may not|may not|
    |voter    |current|referred |un |started |may not|may    |may not|may not|
    |voter    |current|sponsored|un |started |may not|may    |may not|may not|
    |voter    |past   |sponsored|un |started |may not|may not|may not|may not|
    |nonvoter |current|referred |un |started |may not|may not|may not|may not|
    |nonvoter |current|sponsored|un |started |may not|may not|may not|may not|
    |nonmember|current|referred |un |started |may not|may not|may not|may not|
    |nonmember|current|sponsored|un |started |may not|may not|may not|may not|
    |nonmember|current|sponsored|   |started |may    |may not|may not|may not|

@javascript
Scenario Outline: Create/edit a sponsored motion
  When I create a motion as <relationship>
  Then I should see the new motion
  When I update the motion
  Then I should see the edited motion
  Examples:
    |relationship|
    |voter       |
    |staff       |

@javascript
Scenario Outline: Edit a referred motion
  Given I have a referred motion as <relationship>
  When I update the referred motion
  Then I should see the updated referred motion
  Examples:
    |relationship|
    |vicechair   |
    |staff       |

Scenario: List/search/delete a motion

