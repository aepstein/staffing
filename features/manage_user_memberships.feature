Feature: Manage user_memberships
  In order to identify memberships and enrollments for users
  As a user interested in knowing affiliations of a user
  I want to list user memberships

  Background:
    Given a user: "owner" exists with first_name: "John", last_name: "Doe"
    And a position: "current" exists with name: "Current Position"
    And a position: "future" exists with name: "Future Position"
    And a position: "past" exists with name: "Past Position"
    And a membership exists with user: user "owner", position: position "current"
    And a future_membership exists with user: user "owner", position: position "future"
    And a past_membership exists with user: user "owner", position: position "past"
    And a committee "current" exists with name: "Current Committee"
    And a committee "future" exists with name: "Future Committee"
    And a committee "past" exists with name: "Past Committee"
    And an enrollment exists with position: position "current", committee: committee "current", title: "Vice-Chair"
    And an enrollment exists with position: position "future", committee: committee "future", title: "Chair"
    And an enrollment exists with position: position "past", committee: committee "past", title: "Member"
    And a user: "admin" exists with admin: true

  Scenario Outline: Permissions for user-oriented <controller> indices
    Given I log in as user: "<user>"
    And I am on the <controller>s page for user: "<other>"
    Then I should <other_see> authorized
    Given I am on the <controller>s page for user: "<user>"
    Then I should <self> authorized
    Given I am on the current <controller>s page for user: "<other>"
    Then I should <other_see> authorized
    Given I am on the current <controller>s page for user: "<user>"
    Then I should <self> authorized
    Given I am on the future <controller>s page for user: "<other>"
    Then I should <other_see> authorized
    Given I am on the future <controller>s page for user: "<user>"
    Then I should <self> authorized
    Given I am on the past <controller>s page for user: "<other>"
    Then I should <other_see> authorized
    Given I am on the past <controller>s page for user: "<user>"
    Then I should <self> authorized
    Examples:
      | controller | user  | other | other_see | self    |
      | membership | admin | owner | see       | see     |
      | membership | owner | admin | not see   | see     |
      | enrollment | admin | owner | see       | see     |
      | enrollment | owner | admin | not see   | see     |

  Scenario: List enrollments correctly for a user
    Given I log in as user: "owner"
    And I am on the enrollments page for user: "owner"
    Then I should see "Index enrollments for John Doe"
    And I should see the following enrollments:
      |Committee         |Title      |Votes |
      |Current Committee |Vice-Chair |1     |
      |Future Committee  |Chair      |1     |
      |Past Committee    |Member     |1     |
    Given I am on the current enrollments page for user: "owner"
    Then I should see "Current enrollments for John Doe"
    And I should see the following enrollments:
      |Committee         |Title      |Votes |
      |Current Committee |Vice-Chair |1     |
    Given I am on the future enrollments page for user: "owner"
    Then I should see "Future enrollments for John Doe"
    And I should see the following enrollments:
      |Committee         |Title      |Votes |
      |Future Committee  |Chair      |1     |
    Given I am on the past enrollments page for user: "owner"
    Then I should see "Past enrollments for John Doe"
    And I should see the following enrollments:
      |Committee         |Title      |Votes |
      |Past Committee    |Member     |1     |

  Scenario: List memberships correctly for a user
    Given I log in as user: "owner"
    And I am on the memberships page for user: "owner"
    Then I should see "Index memberships for John Doe"
    And I should see the following memberships:
      |Position         |Committees        |
      |Future Position  |Future Committee  |
      |Current Position |Current Committee |
      |Past Position    |Past Committee    |
    Given I am on the current memberships page for user: "owner"
    Then I should see "Current memberships for John Doe"
    And I should see the following memberships:
      |Position         |Committees        |
      |Current Position |Current Committee |
    Given I am on the future memberships page for user: "owner"
    Then I should see "Future memberships for John Doe"
    And I should see the following memberships:
      |Position         |Committees        |
      |Future Position  |Future Committee  |
    Given I am on the past memberships page for user: "owner"
    Then I should see "Past memberships for John Doe"
    And I should see the following memberships:
      |Position         |Committees        |
      |Past Position    |Past Committee    |

