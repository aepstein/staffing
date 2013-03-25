Feature: Manage meeting minute motions
  In order to record minutes of meetings
  As a staff or clerk of a committee
  I want to create, update, and amend meeting minute motions
  @wip @javascript
  Scenario Outline: Create and update minutes motion for meeting
    Given a <meeting> published meeting exists of a committee to which I have a <relation> relationship
    And the meeting has items on its agenda
    When I create a minute motion for the meeting
    Then I should see the new minute motion
    When I update the minute motion
    Then I should see the updated minute motion
    Examples:
      |meeting |relation     |
      |current |current clerk|

  Scenario Outline: Access control
    Given a <meeting> published meeting exists of a committee to which I have a <relation> relationship
    Then I <create> create minute motions for the meeting
    Examples:
      | meeting | relation         | create  |
      | past    | staff            | may     |
      | current | staff            | may     |
      | current | current clerk    | may     |
      | past    | current clerk    | may     |
      | current | recent clerk     | may not |
      | current | current nonvoter | may not |

