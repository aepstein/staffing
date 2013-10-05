Feature: Public motion listings
  In order to disseminate motion information to the public
  As an unauthenticated user
  I want to see summary information for all motions with drill-down

Scenario Outline: Access control
  Given a <tense> <pub>published, <status> motion exists of <origin> origin to which I have a <relationship> relationship
  Then I <show> see the motion through public listings
  Examples:
    |relationship      |tense  |origin   |pub|status  |show   |
    |current sponsor   |current|sponsored|un |started |may    |
    |guest             |current|sponsored|un |started |may not|
    |guest             |current|sponsored|   |started |may    |

