Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Background:
    Given a user: "popular" exists with first_name: "Mister", last_name: "Popularity", net_id: "zzz9999"
    And a user: "unpopular" exists with first_name: "Mister", last_name: "Cellophane", net_id: "zzz9998"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "officer" exists with name: "Officer", schedule: schedule "annual", slots: 4

  Scenario Outline: Test permissions for memberships controller actions
    Given a position exists
    And a membership exists with position: the position
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new membership page for the position
    Then I should <create>
    Given I post on the memberships page for the position
    Then I should <create>
    And I am on the edit page for the membership
    Then I should <update>
    Given I put on the page for the membership
    Then I should <update>
    Given I am on the page for the membership
    Then I should <show>
    Given I am on the memberships page for the position
    Then I should <show>
    Given I delete on the page for the membership
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" |

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
    And I fill in "Designee for Important Committee" with "Mister Cellophane (zzz9998)"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: Mister Popularity"
    And I should see "Period: 1 Jun 2008 - 31 May 2009"
    And I should see "Position: Officer"
    And I should see "Starts at: 1 Jun 2008"
    And I should see "Ends at: 31 May 2009"
    And I should see "Designee for Important Committee: Mister Cellophane"
    When I follow "Edit"
    When I fill in "User" with "Mister Cellophane (zzz9998)"
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
    And a request: "application" exists with user: user "popular", position: position "officer", state: "submitted"
    And period: "2008" is one of the periods of request: "application"
    And I log in as the administrator
    And I am on the new membership page for request: "application"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: Mister Popularity"
    And I should see "Position: Officer"
    And I should see "Starts at: 1 Jun 2008"
    And I should see "Ends at: 31 May 2009"

  Scenario: List memberships for a committee
    Given a committee exists
    And a user: "in" exists with last_name: "User", first_name: "Included"
    And a user: "out" exists with last_name: "User", first_name: "Excluded"
    And a position: "in" exists with slots: 2, schedule: schedule "annual"
    And an enrollment exists with position: position "in", committee: the committee, votes: 1, title: "Member"
    And a membership exists with position: position "in", user: user "in", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "out" exists with schedule: schedule "annual"
    And an enrollment exists with position: position "out"
    And a membership exists with position: position "out", user: user "out", period: period "2008", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And I log in as the administrator
    When I am on the memberships page for the committee
    Then I should see the following memberships:
      |User          |Period                  |Starts at |Ends at    |Title  |Votes |
      |unassigned    |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|Member |1     |
      |Included User |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|Member |1     |

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

