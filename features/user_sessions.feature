Feature: Local authentication
  In order to authenticate identities
  Users must be able to log in and log out

Scenario: Log in
  Given I log in as the plain user
  Then I should be logged in

Scenario: Log in
  Given I have a single sign on net id
  And the single sign on net id is associated with a user
  Then I should automatically log in when required

Scenario: Log out
  Given I log in as the plain user
  Then I can log out

Scenario: Single sign in registration prompt
  Given I have a single sign on net id
  Then I should be prompted to register

