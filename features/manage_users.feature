Feature: Manage users
  In order to represent people in committees
  As an administrator
  I want to create, modify, list, show, and destroy users

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: List authorities on the user profile page
    Given a user: "owner" exists
    And a committee exists
    And position exists
    And an enrollment exists with position: the position, committee: the committee, votes: <votes>
    And a membership exists with user: user "owner", position: the position
    And an authority exists with name: "Important Authority", committee: the committee
    And I log in as user: "owner"
    Then I should see "Important Authority"
    Examples:
      | votes |
      | 0     |
      | 1     |

  Scenario: List in process motions on the user profile page
    Given a user: "owner" exists
    And a schedule exists
    And a period: "current" exists with schedule: the schedule
    And a period: "past" exists before period: "current" with schedule: the schedule
    And a committee exists with schedule: the schedule
    And a position exists
    And an enrollment exists with position: the position, committee: the committee, votes: 1
    And a membership exists with user: user "owner", position: the position, period: period "current"
    And a membership exists with user: user "owner", position: the position, period: period "past"
    And a motion exists with name: "Key motion", period: period "current", committee: the committee
    And a sponsorship exists with motion: the motion, user: the user
    And a motion exists with name: "Implemented motion", period: period "current", status: "implemented", committee: the committee
    And a sponsorship exists with motion: the motion, user: the user
    And a motion exists with position: the position, period: period "past", committee: the committee
    And a sponsorship exists with motion: the motion, user: the user
    And I log in as user: "owner"
    Then I should see "Key motion"
    And I should not see "Old motion"
    And I should not see "Implemented motion"

  Scenario Outline: List committees in which user can vote
    Given a user: "owner" exists
    And a committee exists with name: "Key committee"
    And a position exists
    And an enrollment exists with position: the position, committee: the committee, votes: <votes>
    And a membership exists with user: the user, position: the position
    And I log in as user: "owner"
    Then I should <see> "You may start motions for the following committees:"
#    And I should <see> "Key committee" within "#voting_committees"
    And I should <not_see> "You may not start motions for any committee at this time."
    Examples:
      | votes | see     | not_see |
      | 1     | see     | not see |
      | 0     | not see | see     |

  Scenario: List unexpired requests on user profile page
    Given a user: "owner" exists
    And a position: "expired" exists with name: "Expired Position"
    And a committee: "expired" exists with name: "Expired Committee"
    And an enrollment exists with position: position "expired", committee: committee "expired", requestable: true
    And a position: "unexpired" exists with name: "Unexpired Position"
    And a committee: "unexpired" exists with name: "Unexpired Committee"
    And an enrollment exists with position: position: "unexpired", committee: committee "unexpired", requestable: true
    And a request exists with committee: committee "unexpired", user: the user
    And an expired request exists with committee: committee "expired", user: the user
    And I log in as user: "owner"
    Then I should see "Current Requests"
    And I should see the following entries in "requests":
      | Committee           |
      | Unexpired Committee |
    And I should see "1 expired request"

  Scenario: Set user empl_ids in bulk (from csv text)
    Given a user exists with net_id: "jd1"
    And I log in as user: "admin"
    And I am on the users page
    And I follow "Import empl_ids"
    And I fill in "users" with "jd1,123456"
    And I press "Import empl_ids"
    Then I should see "Processed empl_ids."
    Given I am on the page for the user
    Then I should see "Empl id: 123456"

  Scenario: Set user empl_ids in bulk (from csv file)
    Given a user exists with net_id: "jd1"
    And I log in as user: "admin"
    And I am on the users page
    And I follow "Import empl_ids"
    And I attach the file "spec/assets/empl_ids.csv" to "users_file"
    And I press "Import empl_ids"
    Then I should see "Processed empl_ids."
    Given I am on the page for the user
    Then I should see "Empl id: 123456"

