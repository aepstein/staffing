Feature: Local authentication
  In order to authenticate identities
  Users must be able to log in and log out

Scenario: Log in
  Given I log in as the plain user
  Then I should be logged in

Scenario: Log out
  Given I log in as the plain user
  Then I can log out

