Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Background:
    Given a user: "popular" exists with first_name: "Mister", last_name: "Popularity"
    And a user: "unpopular" exists with first_name: "Mister", last_name: "Cellophane"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a position: "officer" exists with name: "Officer", schedule: schedule "annual", slots: 4

  Scenario: Register new membership
    Given I log in as the administrator
    And I am on the new membership page for position: "officer"
    When I select "Mister Popularity" from "User"
    And I select " 1 Jun 2008 - 31 May 2009" from "Period"
    And I fill in "Starts at" with "2008-06-01"
    And I fill in "Ends at" with "2009-05-31"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: Mister Popularity"
    And I should see "Period:  1 Jun 2008 - 31 May 2009"
    And I should see "Position: Officer"
    And I should see "Starts at:  1 Jun 2008"
    And I should see "Ends at: 31 May 2009"
    When I follow "Edit"
    And I select "Mister Cellophane" from "User"
    And I select " 1 Jun 2009 - 31 May 2010" from "Period"
    And I fill in "Starts at" with "2009-06-01"
    And I fill in "Ends at" with "2010-01-15"
    And I press "Update"
    Then I should see "Membership was successfully updated."
    And I should see "User: Mister Cellophane"
    And I should see "Period:  1 Jun 2009 - 31 May 2010"
    And I should see "Starts at:  1 Jun 2009"
    And I should see "Ends at: 15 Jan 2010"

  Scenario: Delete membership
    Given a user: "user1" exists with first_name: "John", last_name: "Doe 1"
    And a user: "user2" exists with first_name: "John", last_name: "Doe 2"
    And a user: "user3" exists with first_name: "John", last_name: "Doe 3"
    And a user: "user4" exists with first_name: "John", last_name: "Doe 4"
    And a membership exists with position: position "officer", user: user "user4", period: period "2008"
    And a membership exists with position: position "officer", user: user "user3", period: period "2008"
    And a membership exists with position: position "officer", user: user "user2", period: period "2008"
    And a membership exists with position: position "officer", user: user "user1", period: period "2008"
    And I log in as the administrator
    When I delete the 3rd membership for position: "officer"
    Then I should see the following memberships:
      |User       |Period                  |Starts at |Ends at    |
      |John Doe 1 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|
      |John Doe 2 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|
      |John Doe 4 |1 Jun 2008 - 31 May 2009|1 Jun 2008|31 May 2009|

