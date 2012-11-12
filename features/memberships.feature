Feature: Memberships
  In order to record memberships of people in positions
  As a committee authority member or administrator
  I want to create, modify, list, show, and destroy memberships
@wip
Scenario Outline: Access control
  Given an authorization scenario of a <member_tense> membership to which I have a <relation_tense> <relation> relationship
  Then I <show> see the membership
  And I <create> create memberships for the position
  And I <update> update the membership
  And I <destroy> destroy the membership
  Examples:
|member_tense|relation_tense|relation    |show|create |update |destroy|
|current     |current       |admin       |may |may    |may    |may    |
|current     |current       |staff       |may |may    |may    |may not|
|past        |current       |staff       |may |may    |may    |may not|
|current     |current       |authority   |may |may    |may    |may not|
|pending     |current       |authority   |may |may    |may    |may not|
|recent      |current       |authority   |may |may    |may    |may not|
|past        |current       |authority   |may |may    |may not|may not|
|future      |current       |authority   |may |may    |may not|may not|
|current     |current       |authority_ro|may |may not|may not|may not|
|current     |current       |plain       |may |may not|may not|may not|

@javascript
Scenario Outline: Create/edit a sponsored membership
  When I create a membership as <relationship>
  Then I should see the new membership
  When I update the membership
  Then I should see the edited membership
  Examples:
    |relationship|
    |voter       |
    |staff       |

@javascript
Scenario Outline: Edit a referred membership
  Given I have a referred membership as <relationship>
  When I update the referred membership
  Then I should see the updated referred membership
  Examples:
    |relationship|
    |vicechair   |
    |staff       |

Scenario: List/delete a membership
  Given I log in as the admin user
  And there are 4 memberships for a committee
  And I "Destroy" the 3rd membership for the committee
  Then I should see the following memberships for the committee:
  | Membership 4 |
  | Membership 3 |
  | Membership 1 |

Scenario Outline: Membership events without javascript
  Given an authorization scenario of <pub>published, <status> membership of <origin> origin to which I have a <tense> <relation> relationship
  When I <event> the membership
  Then I should see confirmation of the event on the membership
  Examples:
    |relation |tense  |origin   |pub|status   |event   |
    |sponsor  |current|sponsored|un |started  |propose |
    |vicechair|current|referred |   |started  |propose |
    |sponsor  |current|sponsored|   |proposed |withdraw|
    |vicechair|current|sponsored|   |proposed |adopt   |
    |vicechair|current|sponsored|   |proposed |merge   |
    |vicechair|current|sponsored|   |proposed |restart |
    |vicechair|current|sponsored|   |proposed |refer   |

@javascript
Scenario Outline: Membership events with javascript
  Given an authorization scenario of <pub>published, <status> membership of <origin> origin to which I have a <tense> <relation> relationship
  When I <event> the membership
  Then I should see confirmation of the event on the membership
  Examples:
    |relation |tense  |origin   |pub|status   |event   |
    |vicechair|current|sponsored|   |proposed |divide  |
    |vicechair|current|sponsored|   |proposed |merge   |

