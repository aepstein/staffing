Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to create, modify, list, show, and destroy motions

Scenario Outline: Access control
  Given a <tense> <pub>published, <status> motion exists of <origin> origin to which I have a <relationship> relationship
  Then I <show> see the motion
  And I <create> create motions for the committee
  And I <update> update the motion
  And I <destroy> destroy the motion
  Examples:
    |relationship      |tense  |origin   |pub|status  |show   |create |update |destroy|
    |admin             |current|sponsored|un |started |may    |may    |may    |may    |
    |admin             |current|sponsored|   |proposed|may    |may    |may    |may    |
    |admin             |past   |sponsored|un |started |may    |may    |may    |may    |
    |admin             |future |sponsored|un |started |may    |may    |may    |may    |
    |staff             |current|sponsored|un |started |may    |may    |may    |may not|
    |staff             |past   |sponsored|un |started |may    |may    |may    |may not|
    |staff             |future |sponsored|un |started |may    |may    |may    |may not|
    |current vicechair |current|referred |un |started |may    |may    |may    |may not|
    |current vicechair |current|sponsored|un |started |may not|may    |may not|may not|
    |past vicechair    |past   |sponsored|un |started |may not|may not|may not|may not|
    |current nonvoter  |current|sponsored|un |started |may not|may not|may not|may not|
    |current nonsponsor|current|sponsored|un |started |may not|may not|may not|may not|
    |current sponsor   |current|referred |un |started |may    |may    |may    |may not|
    |current sponsor   |current|sponsored|un |started |may    |may    |may    |may not|
    |current sponsor   |current|sponsored|un |proposed|may    |may    |may not|may not|
    |past sponsor      |past   |sponsored|un |started |may    |may not|may not|may not|
    |current voter     |current|referred |un |started |may not|may    |may not|may not|
    |current voter     |current|sponsored|un |started |may not|may    |may not|may not|
    |past voter        |past   |sponsored|un |started |may not|may not|may not|may not|
    |current nonvoter  |current|referred |un |started |may not|may not|may not|may not|
    |current nonvoter  |current|sponsored|un |started |may not|may not|may not|may not|
    |current clerk     |current|meeting  |un |started |may    |may not|may    |may not|
    |plain             |current|referred |un |started |may not|may not|may not|may not|
    |plain             |current|sponsored|un |started |may not|may not|may not|may not|
    |plain             |current|sponsored|   |started |may    |may not|may not|may not|

Scenario Outline: Access control for events
  Given a <tense> <pub>published, <status> motion exists of <origin> origin to which I have a <relationship> relationship
  Then I <permit> <event> the motion
  Examples:
    |relationship     |tense  |origin   |pub|status   |permit |event    |
    |staff            |current|sponsored|un |started  |may    |propose  |
    |current vicechair|current|sponsored|   |started  |may not|propose  |
    |current vicechair|current|referred |   |started  |may    |propose  |
    |current sponsor  |current|sponsored|un |started  |may    |propose  |
    |current clerk    |current|meeting  |un |started  |may    |propose  |
    |past sponsor     |past   |sponsored|un |started  |may not|propose  |
    |plain            |current|sponsored|   |started  |may not|propose  |
    |admin            |current|sponsored|un |started  |may not|watch    |
    |plain            |current|sponsored|   |started  |may    |watch    |
    |admin            |current|sponsored|   |started  |may not|unwatch  |
    |admin            |current|sponsored|   |proposed |may not|propose  |
    |staff            |current|sponsored|   |proposed |may    |adopt    |
    |staff            |current|sponsored|   |proposed |may    |amend    |
    |staff            |current|sponsored|   |proposed |may    |divide   |
    |staff            |current|sponsored|   |proposed |may    |merge    |
    |staff            |current|sponsored|   |proposed |may    |refer    |
    |staff            |current|sponsored|   |proposed |may    |restart  |
    |staff            |current|sponsored|   |proposed |may    |withdraw |
    |current vicechair|current|sponsored|   |proposed |may    |adopt    |
    |current vicechair|current|sponsored|   |proposed |may    |amend    |
    |current vicechair|current|sponsored|   |proposed |may    |divide   |
    |current vicechair|current|sponsored|   |proposed |may    |merge    |
    |current vicechair|current|sponsored|   |proposed |may    |refer    |
    |current vicechair|current|sponsored|   |proposed |may    |restart  |
    |current vicechair|current|sponsored|   |proposed |may    |withdraw |
    |past vicechair   |past   |sponsored|   |proposed |may not|adopt    |
    |past vicechair   |past   |sponsored|   |proposed |may not|amend    |
    |past vicechair   |past   |sponsored|   |proposed |may not|divide   |
    |past vicechair   |past   |sponsored|   |proposed |may not|merge    |
    |past vicechair   |past   |sponsored|   |proposed |may not|refer    |
    |past vicechair   |past   |sponsored|   |proposed |may not|restart  |
    |past vicechair   |past   |sponsored|   |proposed |may not|withdraw |
    |current sponsor  |current|sponsored|   |proposed |may not|adopt    |
    |current sponsor  |current|sponsored|   |proposed |may not|amend    |
    |current sponsor  |current|sponsored|   |proposed |may not|divide   |
    |current sponsor  |current|sponsored|   |proposed |may not|merge    |
    |current sponsor  |current|sponsored|   |proposed |may not|refer    |
    |current sponsor  |current|sponsored|   |proposed |may not|restart  |
    |current sponsor  |current|sponsored|   |proposed |may    |withdraw |
    |past sponsor     |past   |sponsored|   |proposed |may not|withdraw |
    |current voter    |current|sponsored|   |proposed |may not|adopt    |
    |current voter    |current|sponsored|   |proposed |may not|amend    |
    |current voter    |current|sponsored|   |proposed |may not|divide   |
    |current voter    |current|sponsored|   |proposed |may not|merge    |
    |current voter    |current|sponsored|   |proposed |may not|refer    |
    |current voter    |current|sponsored|   |proposed |may not|restart  |
    |current voter    |current|sponsored|   |proposed |may not|withdraw |
    |staff            |current|sponsored|   |adopted  |may    |implement|
    |staff            |current|sponsored|   |adopted  |may    |reject   |
    |staff            |current|sponsored|   |adopted  |may    |refer    |
    |current vicechair|current|sponsored|   |adopted  |may not|implement|
    |current vicechair|current|sponsored|   |adopted  |may not|reject   |
    |current vicechair|current|sponsored|   |adopted  |may not|refer    |
    |current chair    |current|sponsored|   |adopted  |may    |refer    |
    |past chair       |past   |sponsored|   |adopted  |may not|refer    |
    |current sponsor  |current|sponsored|   |adopted  |may not|implement|
    |current sponsor  |current|sponsored|   |adopted  |may not|reject   |
    |current sponsor  |current|sponsored|   |adopted  |may not|refer    |
    |staff            |current|sponsored|   |withdrawn|may    |restart  |
    |current sponsor  |current|sponsored|   |withdrawn|may    |restart  |
    |past sponsor     |past   |sponsored|   |withdrawn|may not|restart  |
    |current vicechair|current|sponsored|   |withdrawn|may not|restart  |
    |admin            |current|sponsored|   |rejected |may not|restart  |
    |admin            |current|sponsored|   |merged   |may not|restart  |
    |admin            |current|sponsored|   |divided  |may not|restart  |

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
  Given a <tense> <pub>published, <status> motion exists of <origin> origin to which I have a <relationship> relationship
  When I <event> the motion
  Then I should see confirmation of the event on the motion
  Examples:
    |relationship     |tense  |origin   |pub|status  |event    |
    |current sponsor  |current|sponsored|un |started |propose  |
    |current sponsor  |current|sponsored|   |proposed|withdraw |

@javascript
Scenario Outline: Motion events with javascript
  Given a <tense> <pub>published, <status> motion exists of <origin> origin to which I have a <relationship> relationship
  When I <event> the motion
  Then I should see confirmation of the event on the motion
  Examples:
    |relationship     |tense  |origin   |pub|status   |event    |
    |current vicechair|current|referred |   |started  |propose  |
    |current vicechair|current|sponsored|   |proposed |adopt    |
    |current vicechair|current|sponsored|   |proposed |restart  |
    |current vicechair|current|sponsored|   |proposed |reject   |
    |current vicechair|current|sponsored|   |proposed |withdraw |
    |staff            |current|sponsored|un |started  |propose  |
    |current vicechair|current|sponsored|   |proposed |amend    |
    |current vicechair|current|sponsored|   |proposed |divide   |
    |current vicechair|current|sponsored|   |proposed |merge    |
    |staff            |current|sponsored|   |adopted  |implement|
    |current vicechair|current|sponsored|   |proposed |refer    |
    |current vicechair|current|sponsored|   |proposed |unamend  |

