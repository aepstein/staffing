Feature: Manage authority memberships
  In order to identify memberships and enrollments for authorities
  As a user interested in knowing affiliations of a authority
  I want to list authority memberships

  Background:
    Given a user: "owner" exists with net_id: "owner", password: "secret", first_name: "John", last_name: "Doe"
    And an authority "focus" exists with name: "Focus Authority"
    And an authority "other" exists with name: "Other Authority"
    And a position: "current" exists with name: "Current Position", authority: authority "focus"
    And a position: "future" exists with name: "Future Position", authority: authority "focus"
    And a position: "past" exists with name: "Past Position", authority: authority "focus"
    And a position: "other" exists with name: "Other Position", authority: authority "other"
    And a membership exists with user: user "owner", position: position "current"
    And a future_membership exists with user: user "owner", position: position "future"
    And a future_membership exists with user: user "owner", position: position "other"
    And a past_membership exists with user: user "owner", position: position "past"

  Scenario: List memberships correctly for an authority
    Given I log in as "owner" with password "secret"
    And I am on the memberships page for authority: "focus"
    Then I should see "Index memberships for Focus Authority"
    And I should see the following memberships:
      |User     |Position         |Committees |
      |John Doe |Future Position  |           |
      |John Doe |Current Position |           |
      |John Doe |Past Position    |           |
    Given I am on the current memberships page for authority: "focus"
    Then I should see "Current memberships for Focus Authority"
    And I should see the following memberships:
      |User     |Position         |Committees |
      |John Doe |Current Position |           |
    Given I am on the future memberships page for authority: "focus"
    Then I should see "Future memberships for Focus Authority"
    And I should see the following memberships:
      |User     |Position         |Committees |
      |John Doe |Future Position  |           |
    Given I am on the past memberships page for authority: "focus"
    Then I should see "Past memberships for Focus Authority"
    And I should see the following memberships:
      |User     |Position         |Committees |
      |John Doe |Past Position    |           |

