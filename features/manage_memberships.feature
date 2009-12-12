@wip
Feature: Manage memberships
  In order to record memberships in positions
  As an administrator
  I want to create, modify, show, list and destroy memberships

  Scenario: Register new membership
    Given I am on the new membership page
    When I fill in "User" with "user 1"
    And I fill in "Period" with "period 1"
    And I fill in "Position" with "position 1"
    And I fill in "Request" with "request 1"
    And I fill in "Starts at" with "starts_at 1"
    And I fill in "Ends at" with "ends_at 1"
    And I press "Create"
    Then I should see "user 1"
    And I should see "period 1"
    And I should see "position 1"
    And I should see "request 1"
    And I should see "starts_at 1"
    And I should see "ends_at 1"

  Scenario: Delete membership
    Given the following memberships:
      |user|period|position|request|starts_at|ends_at|
      |user 1|period 1|position 1|request 1|starts_at 1|ends_at 1|
      |user 2|period 2|position 2|request 2|starts_at 2|ends_at 2|
      |user 3|period 3|position 3|request 3|starts_at 3|ends_at 3|
      |user 4|period 4|position 4|request 4|starts_at 4|ends_at 4|
    When I delete the 3rd membership
    Then I should see the following memberships:
      |User|Period|Position|Request|Starts at|Ends at|
      |user 1|period 1|position 1|request 1|starts_at 1|ends_at 1|
      |user 2|period 2|position 2|request 2|starts_at 2|ends_at 2|
      |user 4|period 4|position 4|request 4|starts_at 4|ends_at 4|

