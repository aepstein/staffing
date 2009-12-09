Feature: Manage user_sessions
  In order to assure users are whom they claim to be
  As a secure service
  I want to log in and log out users

  Scenario: Register new user_session (log in)
    Given I logged in as the administrator

  Scenario: Delete user_session (log out)
    Given I logged in as the administrator
    When I log out
    Then I should see "You logged out successfully."

