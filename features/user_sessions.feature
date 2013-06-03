Feature: Local authentication
  In order to authenticate identities
  Users must be able to log in and log out

Scenario: Log in
  Given I log in as the plain user
  Then I should be logged in

Scenario: Log in with single sign on
  Given I have a single sign on net id
  And the single sign on net id is associated with a user
  When I try to log in with the single sign on
  Then I should be logged in
  
#Scenario: Log in with single sign on and force_sso
#  Given I have a single sign on net id
#  And the single sign on net id is associated with a user
#  When I follow the log in link with forced single sign on
#  Then I should be logged in

Scenario: Log out
  Given I log in as the plain user
  Then I can log out

Scenario: Single sign in registration prompt
  Given I have a single sign on net id
  When I try to log in with the single sign on
  Then I should be prompted to register

#Scenario: Single sign in registration prompt and force_sso
#  Given I have a single sign on net id
#  When I follow the log in link with forced single sign on
#  Then I should be prompted to register

