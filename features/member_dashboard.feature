Feature: Member dashboards
  In order to follow meetings and motions in my committees
  As a member
  I want dashboards to review meetings and motions

  @javascript
  Scenario: See meetings on my meetings dashboard
    Given a current published meeting exists of a committee to which I have a current nonvoter relationship
    When I go to my meetings dashboard
    Then I should see the meeting

  Scenario: See published, unscheduled motions on my motions dashboard
    Given a current published, proposed motion exists of sponsored origin to which I have a current nonvoter relationship
    When I go to my motions dashboard
    Then I should see the motion
    And I should not see the motion with the pending meeting

  Scenario: See published, scheduled motions on my motions dashboard
    Given a current published, proposed motion exists of sponsored origin to which I have a current nonvoter relationship
    And the motion is scheduled for a pending meeting
    When I go to my motions dashboard
    Then I should see the motion with the pending meeting

