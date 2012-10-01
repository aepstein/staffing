Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to create, modify, list, show, and destroy motions

  Background:
    Given a position: "chair" exists with name: "Chair of Committee", slots: 2
    And a position: "voting" exists with name: "Member of Committee", slots: 2
    And a position: "non-voting" exists with name: "Ex-Officio Member of Committee", slots: 2
    And a schedule: "committee" exists
    And a past_period exists with schedule: schedule "committee"
    And a current_period exists with schedule: schedule "committee"
    And a future_period exists with schedule: schedule "committee"
    And a committee: "committee" exists with name: "Active Committee", schedule: the schedule
    And an enrollment exists with position: position "chair", committee: committee "committee", votes: 1, manager: true
    And an enrollment exists with position: position "voting", committee: committee "committee", votes: 1
    And an enrollment exists with position: position "non-voting", committee: committee "committee", votes: 0
    And a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for motions controller actions
    Given a motion: "focus" exists with name: "Focus", committee: committee "committee", period: the <period>_period, status: "<status>", published: true
    And a user: "sponsor" exists
    And a membership exists with user: user "sponsor", position: position "voting", period: the <period>_period
    And a sponsorship exists with motion: the motion, user: user "sponsor"
    And a user: "member" exists
    And a membership exists with user: user "member", position: position "<position>", period: the <period>_period
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the motion
    Given I am on the motions page
    And I am on the motions page for committee: "committee"
    # TODO Display what user is allowed to do to the motion
    Given I put on the propose page for the motion
    Then I should <propose> authorized
    Given the motion has status: "<status>"
    When I put on the withdraw page for the motion
    Then I should <withdraw> authorized
    Given the motion has status: "<status>"
    When I put on the restart page for the motion
    Then I should <restart> authorized
    Given the motion has status: "<status>"
    When I am on the divide page for the motion
    Then I should <divide> authorized
    Given the motion has status: "<status>"
    When I am on the merge page for the motion
    Then I should <merge> authorized
    Given I put on the adopt page for the motion
    Then I should <adopt> authorized
    Given the motion has status: "<status>"
    When I put on the implement page for the motion
    Then I should <implement> authorized
    Given the motion has status: "<status>"
    When I put on the reject page for the motion
    Then I should <reject> authorized
    Given the motion has status: "<status>"
    When I am on the refer page for the motion
    Then I should <refer> authorized
    Given the motion has status: "<status>"
    Examples:
|period |status   |position  |user   |restart|propose|withdraw|divide |merge  |adopt  |implement|reject |refer  |
|current|started  |voting    |admin  |not see|see    |see     |not see|not see|not see|not see  |not see|not see|
|past   |started  |voting    |admin  |not see|see    |see     |not see|not see|not see|not see  |not see|not see|
|future |started  |voting    |admin  |not see|see    |see     |not see|not see|not see|not see  |not see|not see|
|current|started  |voting    |sponsor|not see|see    |see     |not see|not see|not see|not see  |not see|not see|
|past   |started  |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |started  |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|started  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |started  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |started  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|started  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |started  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |started  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|started  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |started  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |started  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|started  |voting    |regular|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|proposed |voting    |admin  |see    |not see|see     |see    |see    |see    |not see  |see    |see    |
|past   |proposed |voting    |admin  |see    |not see|see     |see    |see    |see    |not see  |see    |see    |
|future |proposed |voting    |admin  |see    |not see|see     |see    |see    |see    |not see  |see    |see    |
|current|proposed |voting    |sponsor|not see|not see|see     |not see|not see|not see|not see  |not see|not see|
|past   |proposed |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |proposed |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|proposed |chair     |member |see    |not see|see     |see    |see    |see    |not see  |see    |see    |
|past   |proposed |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |proposed |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|proposed |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |proposed |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |proposed |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|proposed |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |proposed |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |proposed |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|proposed |voting    |regular|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|voting    |admin  |see    |not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |withdrawn|voting    |admin  |see    |not see|not see |not see|not see|not see|not see  |not see|not see|
|future |withdrawn|voting    |admin  |see    |not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|voting    |sponsor|see    |not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |withdrawn|voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |withdrawn|voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |withdrawn|chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |withdrawn|chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |withdrawn|voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |withdrawn|voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |withdrawn|non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |withdrawn|non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|withdrawn|voting    |regular|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|adopted  |voting    |admin  |not see|not see|not see |not see|not see|not see|see      |see    |see    |
|past   |adopted  |voting    |admin  |not see|not see|not see |not see|not see|not see|see      |see    |see    |
|future |adopted  |voting    |admin  |not see|not see|not see |not see|not see|not see|see      |see    |see    |
|current|adopted  |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |adopted  |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |adopted  |voting    |sponsor|not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|adopted  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|see    |
|past   |adopted  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |adopted  |chair     |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|adopted  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |adopted  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |adopted  |voting    |member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|adopted  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|past   |adopted  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|future |adopted  |non-voting|member |not see|not see|not see |not see|not see|not see|not see  |not see|not see|
|current|adopted  |voting    |regular|not see|not see|not see |not see|not see|not see|not see  |not see|not see|

