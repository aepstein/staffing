Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Background:
    Given a user: "popular" exists with first_name: "Mister", last_name: "Popularity", net_id: "zzz9999"
    And a user: "unpopular" exists with first_name: "Mister", last_name: "Cellophane", net_id: "cell@example.org"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "officer" exists with name: "Officer", schedule: schedule "annual", slots: 4, designable: true
    And a user: "admin" exists with admin: true

  Scenario Outline: List search elements for a membership
    Given an authority exists
    And a position exists
    And a user exists
    And a committee exists
    And I log in as user: "admin"
    And I am on the memberships page for the <entity>
    Then I should <authority> "Authority" within "form"
    And I should <position> "Position" within "form"
    And I should <user> "User" within "form"
    And I should <committee> "Committee" within "form"
    Examples:
      | entity    | authority | position | user    | committee |
      | authority | not see   | see      | see     | see       |
      | position  | see       | not see  | see     | see       |
      | user      | see       | see      | not see | see       |
      | committee | see       | see      | see     | not see   |

  Scenario Outline: Search for subset of memberships
    Given an authority: "focus" exists with name: "Focus"
    And an authority: "other" exists with name: "Other"
    And a schedule exists
    And period exists with schedule: the schedule
    And a position: "focus" exists with authority: authority "focus", name: "Focus", schedule: the schedule, slots: 2
    And a position: "other" exists with authority: authority "other", name: "Other", schedule: the schedule, slots: 2
    And a committee: "focus" exists with name: "Focus"
    And a committee: "other" exists with name: "Other"
    And an enrollment: "focus" exists with committee: committee "focus", position: position "focus"
    And an enrollment: "other" exists with committee: committee "other", position: position "other"
    And a user: "focus" exists with last_name: "Focus"
    And a user: "other" exists with last_name: "Other"
    And a membership exists with user: user "focus", position: position "focus", period: the period
    And a membership exists with user: user "<toggle_u>", position: position "<toggle_p>", period: the period
    And I log in as user: "admin"
    Given I am on the memberships page for <context>
    When I fill in "<search>" with "Focus"
    And I press "Search"
    Then I should be on the memberships page for <context>
    And I should see "Focus" within "table"
    And I should not see "Other" within "table"
    Examples:
      | toggle_u | toggle_p | context            | search    |
      | focus    | other    | user: "focus"      | Authority |
      | focus    | other    | user: "focus"      | Position  |
      | focus    | other    | user: "focus"      | Committee |
      | other    | other    | committee: "focus" | User      |

  Scenario: Show join and leave notice sending information
    Given a membership exists with join_notice_at: "2010-01-01 06:00:00", leave_notice_at: "2010-01-01 07:00:00"
    And I log in as user: "admin"
    And I am on the page for the membership
    Then I should see "Join notice at: January 1st, 2010 06:00"
    And I should see "Leave notice at: January 1st, 2010 07:00"

  Scenario: Decline renewal of a membership
    Given a position exists with renewable: true, slots: 1
    And a renewable_membership exists with position: the position
    And user: "admin" has first_name: "Mister", last_name: "Administrator"
    And I log in as user: "admin"
    When I follow "Decline Renewal" for the 1st membership for the position
    And I fill in "Comment" with "No *membership* for you!"
    And I press "Decline Renewal"
    Then I should see "Membership renewal was successfully declined."
    And I should see "Renewal declined at:"
    And I should see "Renewal declined by: Mister Administrator"
    And I should see "Renewal declined comment: No membership for you!"

