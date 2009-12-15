@wip
Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Background:
    Given a user: "member" exists with first_name: "Barack", last_name: "Obama"
    And a schedule: "annual" exists with name: "Annual"
    And a position: "president" exists with name: "President", schedule: schedule "annual"
    And a period exists: "2008" with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a period exists: "2009" with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"

  Scenario: Register new membership
    Given I am on the new membership page for position: "president"
    When I select "John Doe 1" from "User"
    And I select "1 Jun 2008 - 31 May 2009" from "Period"
    And I fill in "Starts at" with "2008-06-01"
    And I fill in "Ends at" with "2009-05-31"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "User: John Doe 1"
    And I should see "Period: 1 Jun 2008 - 31 May 2009"
    And I should see "Position: President"
    And I should see "Request: none"
    And I should see "1 Jun 2008 - 31 May 2009"

  Scenario: Delete membership
    Given a membership exists with position: "president"
    When I delete the 3rd membership
    Then I should see the following memberships:
      |User|Period|Position|Request|Starts at|Ends at|
      |user 1|period 1|position 1|request 1|starts_at 1|ends_at 1|
      |user 2|period 2|position 2|request 2|starts_at 2|ends_at 2|
      |user 4|period 4|position 4|request 4|starts_at 4|ends_at 4|

