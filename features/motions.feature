Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to create, modify, list, show, and destroy motions

Scenario Outline: Access control
  Given an authorization scenario of <pub>published, <status> motion of <origin> origin to which I have a <tense> <relation> relationship
  Then I <show> see the motion
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
    |sponsor  |current|sponsored|un |proposed|may    |may    |may not|may not|
    |sponsor  |past   |sponsored|un |started |may    |may not|may not|may not|
    |voter    |current|referred |un |started |may not|may    |may not|may not|
    |voter    |current|sponsored|un |started |may not|may    |may not|may not|
    |voter    |past   |sponsored|un |started |may not|may not|may not|may not|
    |nonvoter |current|referred |un |started |may not|may not|may not|may not|
    |nonvoter |current|sponsored|un |started |may not|may not|may not|may not|
    |nonmember|current|referred |un |started |may not|may not|may not|may not|
    |nonmember|current|sponsored|un |started |may not|may not|may not|may not|
    |nonmember|current|sponsored|   |started |may    |may not|may not|may not|

Scenario Outline: Access control for events
  Given an authorization scenario of <pub>published, <status> motion of <origin> origin to which I have a <tense> <relation> relationship
  Then I <permit> <event> the motion
  Examples:
    |relation |tense  |origin   |pub|status   |permit |event    |
    |staff    |current|sponsored|un |started  |may    |propose  |
    |vicechair|current|sponsored|   |started  |may not|propose  |
    |vicechair|current|referred |   |started  |may    |propose  |
    |sponsor  |current|sponsored|un |started  |may    |propose  |
    |sponsor  |past   |sponsored|un |started  |may not|propose  |
    |nonmember|current|sponsored|   |started  |may not|propose  |
    |admin    |current|sponsored|   |proposed |may not|propose  |
    |staff    |current|sponsored|   |proposed |may    |adopt    |
    |staff    |current|sponsored|   |proposed |may    |amend    |
    |staff    |current|sponsored|   |proposed |may    |divide   |
    |staff    |current|sponsored|   |proposed |may    |merge    |
    |staff    |current|sponsored|   |proposed |may    |refer    |
    |staff    |current|sponsored|   |proposed |may    |restart  |
    |staff    |current|sponsored|   |proposed |may    |withdraw |
    |vicechair|current|sponsored|   |proposed |may    |adopt    |
    |vicechair|current|sponsored|   |proposed |may    |amend    |
    |vicechair|current|sponsored|   |proposed |may    |divide   |
    |vicechair|current|sponsored|   |proposed |may    |merge    |
    |vicechair|current|sponsored|   |proposed |may    |refer    |
    |vicechair|current|sponsored|   |proposed |may    |restart  |
    |vicechair|current|sponsored|   |proposed |may    |withdraw |
    |vicechair|past   |sponsored|   |proposed |may not|adopt    |
    |vicechair|past   |sponsored|   |proposed |may not|amend    |
    |vicechair|past   |sponsored|   |proposed |may not|divide   |
    |vicechair|past   |sponsored|   |proposed |may not|merge    |
    |vicechair|past   |sponsored|   |proposed |may not|refer    |
    |vicechair|past   |sponsored|   |proposed |may not|restart  |
    |vicechair|past   |sponsored|   |proposed |may not|withdraw |
    |sponsor  |current|sponsored|   |proposed |may not|adopt    |
    |sponsor  |current|sponsored|   |proposed |may not|amend    |
    |sponsor  |current|sponsored|   |proposed |may not|divide   |
    |sponsor  |current|sponsored|   |proposed |may not|merge    |
    |sponsor  |current|sponsored|   |proposed |may not|refer    |
    |sponsor  |current|sponsored|   |proposed |may not|restart  |
    |sponsor  |current|sponsored|   |proposed |may    |withdraw |
    |sponsor  |past   |sponsored|   |proposed |may not|withdraw |
    |voter    |current|sponsored|   |proposed |may not|adopt    |
    |voter    |current|sponsored|   |proposed |may not|amend    |
    |voter    |current|sponsored|   |proposed |may not|divide   |
    |voter    |current|sponsored|   |proposed |may not|merge    |
    |voter    |current|sponsored|   |proposed |may not|refer    |
    |voter    |current|sponsored|   |proposed |may not|restart  |
    |voter    |current|sponsored|   |proposed |may not|withdraw |
    |staff    |current|sponsored|   |adopted  |may    |implement|
    |staff    |current|sponsored|   |adopted  |may    |reject   |
    |staff    |current|sponsored|   |adopted  |may    |refer    |
    |vicechair|current|sponsored|   |adopted  |may not|implement|
    |vicechair|current|sponsored|   |adopted  |may not|reject   |
    |vicechair|current|sponsored|   |adopted  |may    |refer    |
    |vicechair|past   |sponsored|   |adopted  |may not|refer    |
    |sponsor  |current|sponsored|   |adopted  |may not|implement|
    |sponsor  |current|sponsored|   |adopted  |may not|reject   |
    |sponsor  |current|sponsored|   |adopted  |may not|refer    |
    |staff    |current|sponsored|   |withdrawn|may    |restart  |
    |sponsor  |current|sponsored|   |withdrawn|may    |restart  |
    |sponsor  |past   |sponsored|   |withdrawn|may not|restart  |
    |vicechair|current|sponsored|   |withdrawn|may not|restart  |
    |admin    |current|sponsored|   |rejected |may not|restart  |
    |admin    |current|sponsored|   |merged   |may not|restart  |
    |admin    |current|sponsored|   |divided  |may not|restart  |

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

Scenario: List/delete a motion
  Given I log in as the admin user
  And there are 4 motions for a committee
  And I "Destroy" the 3rd motion for the committee
  Then I should see the following motions for the committee:
  | Motion 4 |
  | Motion 3 |
  | Motion 1 |

Scenario Outline: Motion events without javascript
  Given an authorization scenario of <pub>published, <status> motion of <origin> origin to which I have a <tense> <relation> relationship
  When I <event> the motion
  Then I should see confirmation of the event on the motion
  Examples:
    |relation |tense  |origin   |pub|status   |event    |
    |sponsor  |current|sponsored|un |started  |propose  |
    |vicechair|current|referred |   |started  |propose  |
    |sponsor  |current|sponsored|   |proposed |withdraw |
    |vicechair|current|sponsored|   |proposed |adopt    |
    |vicechair|current|sponsored|   |proposed |merge    |
    |vicechair|current|sponsored|   |proposed |restart  |
    |vicechair|current|sponsored|   |proposed |refer    |
    |staff    |current|sponsored|   |adopted  |implement|
    |vicechair|current|sponsored|   |proposed |reject   |
    |vicechair|current|sponsored|   |proposed |withdraw |

@javascript
Scenario Outline: Motion events with javascript
  Given an authorization scenario of <pub>published, <status> motion of <origin> origin to which I have a <tense> <relation> relationship
  When I <event> the motion
  Then I should see confirmation of the event on the motion
  Examples:
    |relation |tense  |origin   |pub|status   |event   |
    |vicechair|current|sponsored|   |proposed |amend   |
    |vicechair|current|sponsored|   |proposed |divide  |
    |vicechair|current|sponsored|   |proposed |merge   |

