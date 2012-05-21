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

  # Note: we are testing "create" always with a current membership
  Scenario Outline: Test permissions for memberships controller actions
    Given a committee: "authority" exists
    And a schedule exists
    And a past_period exists with schedule: the schedule
    And a current_period exists with schedule: the schedule
    And a future_period exists with schedule: the schedule
    And a position: "authority" exists with schedule: the schedule
    And an enrollment exists with committee: committee "authority", position: position "authority"
    And an authority: "authority" exists with committee: committee "authority"
    And a user: "authority" exists
    And a membership exists with user: user "authority", position: position "authority", period: the <authority>_period
    And a position: "authority_ro" exists with schedule: the schedule
    And an enrollment exists with committee: committee "authority", position: position "authority_ro", votes: 0
    And a user: "authority_ro" exists
    And a membership exists with user: user "authority_ro", position: position "authority_ro", period: the <authority>_period
    And a position: "focus" exists with name: "Focus Position", authority: authority "authority", schedule: the schedule
    And a user: "owner" exists with net_id: "owner", password: "secret", admin: false, last_name: "Owner"
    And a membership: "focus" exists with position: position "focus", user: user "owner", period: the <membership>_period
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the new membership page for position: "focus"
    Then I should <create> authorized
    Given I post on the memberships page for position: "focus"
    Then I should <create> authorized
    And I am on the edit page for membership: "focus"
    Then I should <update> authorized
    Given I put on the page for membership: "focus"
    Then I should <update> authorized
    Given I am on the page for membership: "focus"
    Then I should <show> authorized
    Given I am on the memberships page for position: "focus"
    Then I should <index> "Owner"
    Given I delete on the page for membership: "focus"
    Then I should <destroy> authorized
    Examples:
      | authority | membership | user         | create  | update  | destroy | index | show    |
      | current   | current    | admin        | see     | see     | see     | see   | see     |
      | current   | current    | authority    | see     | see     | see     | see   | see     |
      | future    | future     | authority    | not see | see     | see     | see   | see     |
      | future    | current    | authority    | not see | not see | not see | see   | see     |
      | current   | future     | authority    | see     | not see | not see | see   | see     |
      | current   | past       | authority    | see     | not see | not see | see   | see     |
      | past      | past       | authority    | not see | not see | not see | see   | see     |
      | current   | current    | authority_ro | not see | not see | not see | see   | see     |
      | future    | future     | authority_ro | not see | not see | not see | see   | see     |
      | future    | current    | authority_ro | not see | not see | not see | see   | see     |
      | current   | future     | authority_ro | not see | not see | not see | see   | see     |
      | current   | past       | authority_ro | not see | not see | not see | see   | see     |
      | past      | past       | authority_ro | not see | not see | not see | see   | see     |
      | current   | current    | owner        | not see | not see | not see | see   | see     |
      | current   | current    | regular      | not see | not see | not see | see   | see     |

  Scenario: Register new membership given a position or edit
    Given a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a committee exists with name: "Important Committee"
    And an enrollment exists with position: position "officer", committee: the committee
    And I log in as user: "admin"
    And I am on the new membership page for position: "officer"
    When I fill in "User" with "Mister Popularity (zzz9999)"
    And I select "1 Jun 2008 - 31 May 2009" from "Period"
    And I fill in "Starts at" with "2008-06-01"
    And I fill in "Ends at" with "2009-05-31"
    And I fill in "Designee for Important Committee" with "Mister Cellophane (cell@example.org)"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: Mister Popularity"
    And I should see "Period: 1 Jun 2008 - 31 May 2009"
    And I should see "Position: Officer"
    And I should see "Starts at: 1 Jun 2008"
    And I should see "Ends at: 31 May 2009"
    And I should not see "Join notice sent at"
    And I should not see "Leave notice sent at"
    And I should see "Designee for Important Committee: Mister Cellophane"
    When I follow "Edit"
    And I fill in "User" with "Mister Cellophane (cell@example.org)"
    And I select "1 Jun 2009 - 31 May 2010" from "Period"
    And I fill in "Starts at" with "2009-06-01"
    And I fill in "Ends at" with "2010-01-15"
    And I check "Check to remove this designee"
    And I press "Update"
    Then I should see "Membership was successfully updated."
    And I should see "User: Mister Cellophane"
    And I should see "Period: 1 Jun 2009 - 31 May 2010"
    And I should see "Starts at: 1 Jun 2009"
    And I should see "Ends at: 15 Jan 2010"
    And I should not see "Designee for Important Committee"

  Scenario:  Show join and leave notice sending information
    Given a membership exists with join_notice_at: "2010-01-01 06:00:00", leave_notice_at: "2010-01-01 07:00:00"
    And I log in as user: "admin"
    And I am on the page for the membership
    Then I should see "Join notice at: January 1st, 2010 06:00"
    And I should see "Leave notice at: January 1st, 2010 07:00"

  Scenario: Delete membership
    Given a user: "user1" exists with first_name: "John", last_name: "Doe 1"
    And a user: "user2" exists with first_name: "John", last_name: "Doe 2"
    And a user: "user3" exists with first_name: "John", last_name: "Doe 3"
    And a user: "user4" exists with first_name: "John", last_name: "Doe 4"
    And a membership exists with position: position "officer", user: user "user4", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user3", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user2", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user1", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd membership for position: "officer"
    Then I should see the following memberships:
      | User       | Period                   | Starts at  | Ends at     |
      | unassigned | 1 Jun 2008 - 31 May 2009 | 1 Jun 2008 | 31 May 2009 |
      | John Doe 1 | 1 Jun 2008 - 31 May 2009 | 1 Jun 2008 | 31 May 2009 |
      | John Doe 2 | 1 Jun 2008 - 31 May 2009 | 1 Jun 2008 | 31 May 2009 |
      | John Doe 4 | 1 Jun 2008 - 31 May 2009 | 1 Jun 2008 | 31 May 2009 |

