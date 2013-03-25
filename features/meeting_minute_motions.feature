Feature: Manage meeting minute motions
  In order to record minutes of meetings
  As a staff or clerk of a committee
  I want to create, update, and amend meeting minute motions
  @wip
  Scenario: Create and update minutes motion for meeting
    Given a <meeting> published meeting exists of a committee to which I have a <relation> relationship
    And the meeting has items on its agenda
    When I create a minutes motion for the meeting
    Then I should see the new minutes motion
    When I update the minutes motion
    Then I should see the updated minutes motion
    Examples:
      |meeting |relation     |
      |current |current clerk|
  @wip
  Scenario: Access control
    Given a <meeting> published meeting exists of a committee to which I have a <relation> relationship
    Then I <create> create minute motions for the meeting

