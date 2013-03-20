Feature: Member dashboards
  In order to follow meetings and motions in my committees
  As a member
  I want dashboards to review meetings and motions

  @javascript
  Scenario Outline: See meetings on my meetings dashboard
    Given a current published meeting exists of a committee to which I have a <relationship> relationship
    When I go to my meetings dashboard
    Then I should <see> the meeting
    Examples:
      | relationship     | see     |
      | current nonvoter | see     |
      | staff            | see     |
      | plain            | not see |

  Scenario Outline: See a current motion
    Given a <period> published, proposed motion exists of sponsored origin to which I have a <relation> relationship
    When I go to my motions dashboard
    Then I should <see> the motion
    Examples:
    | period  | relation        | see     |
    | current | current voter   | not see |
    | current | current sponsor | see     |
    | past    | past sponsor    | not see |
    | current | watcher         | see     |
    | past    | watcher         | not see |
@wip
  Scenario Outline: Create a motion
    Given a <period> published, proposed motion exists of sponsored origin to which I have a <relation> relationship
    Then I <create> create motions for the committee through my dashboard
    Examples:
    | period  | relation           | create  |
    | current | admin              | may     |
    | current | current voter      | may     |
    | past    | past voter         | may not |
    | current | current nonsponsor | may not |
    | current | current nonvoter   | may not |

