Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Background:
    Given a user: "popular" exists with first_name: "Mister", last_name: "Popularity", net_id: "zzz9999"
    And a user: "unpopular" exists with first_name: "Mister", last_name: "Cellophane", net_id: "cell@example.org"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "officer" exists with name: "Officer", schedule: schedule "annual", slots: 4

  Scenario Outline: List search elements for a membership
    Given an authority exists
    And a position exists
    And a user exists
    And a committee exists
    And I log in as the administrator
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
    And I log in as the administrator
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

  Scenario Outline: Test permissions for memberships controller actions
    Given a committee: "authority" exists
    And a position: "authority" exists
    And an enrollment exists with committee: committee "authority", position: position "authority"
    And an authority: "authority" exists with committee: committee "authority"
    And a user: "authority" exists with net_id: "authority", password: "secret", admin: false
    And a membership exists with user: user "authority", position: position "authority"
    And a position: "focus" exists with name: "Focus Position", authority: authority "authority"
    And a user: "owner" exists with net_id: "owner", password: "secret", admin: false, last_name: "Owner"
    And a membership: "focus" exists with position: position "focus", user: user "owner"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new membership page for position: "focus"
    Then I should <create> "not authorized"
    Given I post on the memberships page for position: "focus"
    Then I should <create> "not authorized"
    And I am on the edit page for membership: "focus"
    Then I should <update> "not authorized"
    Given I put on the page for membership: "focus"
    Then I should <update> "not authorized"
    Given I am on the page for membership: "focus"
    Then I should <show> "not authorized"
    Given I am on the memberships page for position: "focus"
    Then I should <index> "Owner"
    Given I delete on the page for membership: "focus"
    Then I should <destroy> "not authorized"
    Examples:
      | user      | create  | update  | destroy | index | show    |
      | admin     | not see | not see | not see | see   | not see |
      | authority | not see | not see | not see | see   | not see |
      | owner     | see     | see     | see     | see   | not see |
      | regular   | see     | see     | see     | see   | not see |

  Scenario: Register new membership given a position or edit
    Given a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a committee exists with name: "Important Committee"
    And an enrollment exists with position: position "officer", committee: the committee
    And I log in as the administrator
    And I am on the new membership page for position: "officer"
    When I fill in "User" with "Mister Popularity (zzz9999)"
    And I select " 1 Jun 2008 - 31 May 2009" from "Period"
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
    And I should see "Designee for Important Committee: Mister Cellophane"
    When I follow "Edit"
    When I fill in "User" with "Mister Cellophane (cell@example.org)"
    And I select " 1 Jun 2009 - 31 May 2010" from "Period"
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

  Scenario: Register a new membership given a request
    Given a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a request: "application" exists with user: user "popular", requestable: position "officer", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And I log in as the administrator
    And I am on the new membership page for request: "application"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: Mister Popularity"
    And I should see "Position: Officer"
    And I should see "Starts at: 1 Jun 2009"
    And I should see "Ends at: 31 May 2010"

  Scenario: Delete membership
    Given a user: "user1" exists with first_name: "John", last_name: "Doe 1"
    And a user: "user2" exists with first_name: "John", last_name: "Doe 2"
    And a user: "user3" exists with first_name: "John", last_name: "Doe 3"
    And a user: "user4" exists with first_name: "John", last_name: "Doe 4"
    And a membership exists with position: position "officer", user: user "user4", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user3", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user2", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a membership exists with position: position "officer", user: user "user1", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And I log in as the administrator
    When I delete the 3rd membership for position: "officer"
    Then I should see the following memberships:
      |User       |Period                  |Starts at |Ends at    |
      |unassigned |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|
      |John Doe 1 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|
      |John Doe 2 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|
      |John Doe 4 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|

