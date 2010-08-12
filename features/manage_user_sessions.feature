Feature: Manage user_sessions
  In order to assure users are whom they claim to be
  As a secure service
  I want to log in and log out users

  Background:
    Given a user: "owner" exists

  Scenario: Register new user_session (log in)
    Given I log in as user: "owner"
    Then I should see "You logged in successfully."

  Scenario: Delete user_session (log out)
    Given I log in as user: "owner"
    When I log out
    Then I should see "You logged out successfully."

