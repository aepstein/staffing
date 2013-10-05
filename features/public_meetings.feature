Feature: Public meeting listings
  In order to disseminate meeting information to the public
  As an unauthenticated user
  I want to see summary information for all meetings with appropriate drill-down

Scenario Outline: Access control
  Given a <tense> <pub>published meeting exists of a committee to which I have a <relationship> relationship
  Then I <show> drill down on the meeting through public listings
  Examples:
    |relationship    |pub|tense  |show   |
    |current chair   |un |pending|may    |
    |recent chair    |un |pending|may not|
    |guest           |   |pending|may    |

