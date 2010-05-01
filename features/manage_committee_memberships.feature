Feature: Manage committee memberships
  In order to identify memberships and enrollments for users
  As a user interested in knowing affiliations of a user
  I want to list user memberships

  Background:
    Given a user: "owner" exists with net_id: "owner", password: "secret", first_name: "John", last_name: "Doe"
    And a position: "current" exists with name: "Current Position"
    And a position: "future" exists with name: "Future Position"
    And a position: "past" exists with name: "Past Position"
    And a position: "other" exists with name: "Other Position"
    And a membership exists with user: user "owner", position: position "current"
    And a future_membership exists with user: user "owner", position: position "future"
    And a future_membership exists with user: user "owner", position: position "other"
    And a past_membership exists with user: user "owner", position: position "past"
    And a committee "focus" exists with name: "Focus Committee"
    And a committee "other" exists with name: "Other Committee"
    And an enrollment exists with position: position "current", committee: committee "focus", title: "Vice-Chair"
    And an enrollment exists with position: position "future", committee: committee "focus", title: "Chair"
    And an enrollment exists with position: position "other", committee: committee "other", title: "Vice-Chair"
    And an enrollment exists with position: position "past", committee: committee "focus", title: "Member"

  Scenario: List enrollments correctly for a committee
    Given I log in as "owner" with password "secret"
    And I am on the enrollments page for committee: "focus"
    Then I should see "Index enrollments for Focus Committee"
    And I should see the following enrollments:
      |Position         |Title      |Votes |
      |Future Position  |Chair      |1     |
      |Past Position    |Member     |1     |
      |Current Position |Vice-Chair |1     |

  Scenario: List memberships correctly for a committee
    Given I log in as "owner" with password "secret"
    And I am on the memberships page for committee: "focus"
    Then I should see "Index memberships for Focus Committee"
    And I should see the following memberships:
      |User     |Position         |Title      |Votes |
      |John Doe |Future Position  |Chair      |1     |
      |John Doe |Current Position |Vice-Chair |1     |
      |John Doe |Past Position    |Member     |1     |
    Given I am on the current memberships page for committee: "focus"
    Then I should see "Current memberships for Focus Committee"
    And I should see the following memberships:
      |User     |Position         |Title      |Votes |
      |John Doe |Current Position |Vice-Chair |1     |
    Given I am on the future memberships page for committee: "focus"
    Then I should see "Future memberships for Focus Committee"
    And I should see the following memberships:
      |User     |Position         |Title      |Votes |
      |John Doe |Future Position  |Chair      |1     |
    Given I am on the past memberships page for committee: "focus"
    Then I should see "Past memberships for Focus Committee"
    And I should see the following memberships:
      |User     |Position         |Title      |Votes |
      |John Doe |Past Position    |Member     |1     |

