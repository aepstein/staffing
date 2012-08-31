Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to create, modify, list, show, and destroy motions

  Background:
    Given a position: "voting" exists with name: "Member of Committee", slots: 2
    And a position: "non-voting" exists with name: "Ex-Officio Member of Committee", slots: 2
    And a schedule: "committee" exists
    And a past_period exists with schedule: schedule "committee"
    And a current_period exists with schedule: schedule "committee"
    And a future_period exists with schedule: schedule "committee"
    And a committee: "committee" exists with name: "Active Committee", schedule: the schedule
    And an enrollment exists with position: position "voting", committee: committee "committee", votes: 1
    And an enrollment exists with position: position "non-voting", committee: committee "committee", votes: 0
    And a user: "admin" exists with admin: true
@wip
  Scenario Outline: Test permissions for motions controller actions
    Given a motion: "focus" exists with name: "Focus", committee: committee "committee", period: the <period>_period, status: "<status>"
    And a user: "sponsor" exists
    And a membership exists with user: user "sponsor", position: position "voting", period: the <period>_period
    And a sponsorship exists with motion: the motion, user: user "sponsor"
    And a user: "member" exists
    And a membership exists with user: user "member", position: position "<position>", period: the <period>_period
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the motion
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the motions page
    And I am on the motions page for committee: "committee"
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New motion"
    Given I am on the new motion page for committee: "committee"
    Then I should <create> authorized
    Given I post on the motions page for committee: "committee"
    Then I should <create> authorized
    When I am on the edit page for the motion
    Then I should <update> authorized
    Given I put on the page for the motion
    Then I should <update> authorized
    Given I put on the propose page for the motion
    Then I should <propose> authorized
    Given I put on the withdraw page for the motion
    Then I should <withdraw> authorized
    Given the motion has status: "<status>"
    When I put on the restart page for the motion
    Then I should <restart> authorized
    Given the motion has status: "<status>"
    When I am on the divide page for the motion
    Then I should <divide> authorized
    Given I am on the merge page for the motion
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
    When I delete on the page for the motion
    Then I should <destroy> authorized
    Examples:
|period |status |position  |user   |create |update |destroy|show   |restart|propose |withdraw|divide |merge  |adopt  |implement|reject |refer  |
|current|started|voting    |admin  |see    |see    |see    |see    |not see|see     |see     |not see|not see|not see|not see  |not see|not see|
|past   |started|voting    |admin  |see    |see    |see    |see    |not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|future |started|voting    |admin  |see    |see    |see    |see    |not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|current|started|voting    |sponsor|see    |see    |see    |see    |not see|see     |see     |not see|not see|not see|not see  |not see|not see|
|past   |started|voting    |sponsor|not see|not see|not see|see    |not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|future |started|voting    |sponsor|not see|not see|not see|see    |not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|current|started|voting    |member |see    |not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|past   |started|voting    |member |not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|future |started|voting    |member |not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|current|started|non-voting|member |not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|past   |started|non-voting|member |not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|future |started|non-voting|member |not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|
|current|started|voting    |regular|not see|not see|not see|not see|not see|not see |not see |not see|not see|not see|not see  |not see|not see|

  @javascript
  Scenario: Register new motion
    Given a schedule exists
    And a period: "focus" exists with schedule: the schedule, starts_at: "2010-01-01", ends_at: "2010-12-31"
    And a period exists with schedule: the schedule, starts_at: "2009-01-01", ends_at: "2009-12-31"
    And a committee exists with name: "Powerful Committee", schedule: the schedule
    And a user: "abc1" exists with first_name: "George", last_name: "Washington", net_id: "abc1"
    And a user: "abc2" exists with first_name: "John", last_name: "Adams", net_id: "abc2"
    And a position exists with schedule: the schedule, slots: 2
    And an enrollment exists with committee: the committee, position: the position
    And a membership exists with period: period "focus", position: the position, user: user "abc1"
    And a membership exists with period: period "focus", position: the position, user: user "abc2"
    And I log in as user: "admin"
    And I am on the new motion page for the committee
    When I select "1 Jan 2010 - 31 Dec 2010" from "Period"
    And I fill in "Name" with "Charter amendment"
    And I fill in "Description" with "This is a *big* change."
    And I fill in "Content" with "*Whereas* and *Resolved*"
    And I fill in "Sponsor" with "abc1"
    And I follow "add attachment"
    And I attach the file "spec/assets/empl_ids.csv" to "Attachment document"
    And I fill in "Attachment description" with "Sample employee ids"
    And I press "Create"
    Then I should see "Motion was successfully created."
    And I should see "Committee: Powerful Committee"
    And I should see "Period: 1 Jan 2010 - 31 Dec 2010"
    And I should see "Name: Charter amendment"
    And I should see "George Washington"
    And I should see "This is a big change."
    And I should see "Whereas and Resolved"
    And I should see "Sample employee ids"
    When I follow "Edit"
    And I fill in "Name" with "Charter change"
    And I fill in "Description" with "This is a big change."
    And I fill in "Content" with "Whereas and Finally Resolved"
    And I follow "remove sponsorship"
    And I follow "add sponsorship"
    And I follow "remove attachment"
    And I fill in "Sponsor" with "abc2"
    And I press "Update"
    Then I should see "Motion was successfully updated."
    And I should see "Name: Charter change"
    And I should see "This is a big change."
    And I should see "Whereas and Finally Resolved"
    And I should see "John Adams"
    And I should not see "George Washington"
    And I should not see "Sample employee ids"

  Scenario: Delete motion
    Given there are no motions
    And a schedule exists
    And a period exists with schedule: the schedule, starts_at: "2010-01-01", ends_at: "2010-12-31"
    And a committee exists with schedule: the schedule
    And a motion exists with name: "Motion 4", committee: the committee
    And a motion exists with name: "Motion 3", committee: the committee
    And a motion exists with name: "Motion 2", committee: the committee
    And a motion exists with name: "Motion 1", committee: the committee
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd motion for the committee
    Then I should see the following motions:
      | Period                   | Position | Name     |
      | 1 Jan 2010 - 31 Dec 2010 | 1        | Motion 4 |
      | 1 Jan 2010 - 31 Dec 2010 | 2        | Motion 3 |
      | 1 Jan 2010 - 31 Dec 2010 | 3        | Motion 1 |

