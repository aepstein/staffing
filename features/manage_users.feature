Feature: Manage users
  In order to represent people in committees
  As an administrator
  I want to create, modify, list, show, and destroy users

  Background:
    Given a user: "admin" exists with admin: true

  Scenario: List unexpired requests on user profile page
    Given a user: "owner" exists
    And a position: "expired" exists with name: "Expired Position"
    And a committee: "expired" exists with name: "Expired Committee"
    And an enrollment exists with position: position "expired", committee: committee "expired", requestable: true
    And a position: "unexpired" exists with name: "Unexpired Position"
    And a committee: "unexpired" exists with name: "Unexpired Committee"
    And an enrollment exists with position: position: "unexpired", committee: committee "unexpired", requestable: true
    And a request exists with committee: committee "unexpired", user: the user
    And an expired request exists with committee: committee "expired", user: the user
    And I log in as user: "owner"
    Then I should see "Current Requests"
    And I should see the following entries in "requests":
      | Committee           |
      | Unexpired Committee |
    And I should see "1 expired request"

