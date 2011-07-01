Feature: Manage users
  In order to represent people in committees
  As an administrator
  I want to create, modify, list, show, and destroy users

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for schedules controller actions
    Given a user: "owner" exists with net_id: "owner", password: "secret", admin: false, first_name: "The", last_name: "Owner"
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a user: "authority" exists
    And a committee exists
    And a position exists
    And an enrollment exists with committee: the committee, position: the position, votes: 1
    And a membership exists with user: user "authority", position: the position
    And an authority exists with committee: the committee
    And I log in as user: "<user>"
    And I am on the page for the user: "owner"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the users page
    Then I should <show> "Owner, The"
#    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New user"
    Given I am on the new user page
    Then I should <create> authorized
    Given I post on the users page
    Then I should <create> authorized
    Given I am on the edit page for the user: "owner"
    Then I should <update> authorized
    Given I put on the page for the user: "owner"
    Then I should <update> authorized
    Given I delete on the page for the user: "owner"
    Then I should <destroy> authorized
    Examples:
      | user      | create  | update  | destroy | show    |
      | admin     | see     | see     | see     | see     |
      | owner     | not see | see     | not see | see     |
      | authority | not see | not see | not see | see     |
      | regular   | not see | not see | not see | not see |

  Scenario: List authorities on the user profile page
    Given a user: "owner" exists
    And a committee exists
    And position exists
    And an enrollment exists with position: the position, committee: the committee
    And a membership exists with user: user "owner", position: the position
    And an authority exists with name: "Important Authority", committee: the committee
    And I log in as user: "owner"
    Then I should see "Important Authority"

  Scenario: List unexpired requests on user profile page
    Given a user: "owner" exists
    And a position: "expired" exists with name: "Expired Position"
    And a position: "unexpired" exists with name: "Unexpired Position"
    And a request exists with requestable: position "unexpired", user: the user
    And an expired request exists with requestable: position "expired", user: the user
    And I log in as user: "owner"
    Then I should see "Current Requests"
    And I should see the following entries in "requests":
      | Requestable        |
      | Unexpired Position |
    And I should see "1 expired request"

  Scenario: Register new user and edit
    Given I log in as user: "admin"
    And I am on the new user page
    When I fill in "First name" with "John"
    And I fill in "Middle name" with "Nobody"
    And I fill in "Last name" with "Doe"
    And I fill in "Net" with "fake"
    And I fill in "Email" with "jd@example.com"
    And I fill in "Mobile phone" with "607-555-1212"
    And I fill in "Work phone" with "607-555-1234"
    And I fill in "Home phone" with "607-555-4321"
    And I fill in "Work address" with "100 Day Hall"
    And I fill in "Date of birth" with "1982-06-04"
    And I choose "Yes"
    And I press "Create"
    Then I should see "User was successfully created."
    And I should see "First name: John"
    And I should see "Middle name: Nobody"
    And I should see "Last name: Doe"
    And I should see "Net id: fake"
    And I should see "Email: jd@example.com"
    And I should see "Mobile phone: (607) 555-1212"
    And I should see "Work phone: (607) 555-1234"
    And I should see "Home phone: (607) 555-4321"
    And I should see "Work address: 100 Day Hall"
    And I should see "Date of birth: June 4, 1982"
    And I should see "Resume? No"
    And I should see "Statuses: unknown"
    And I should see "Administrator? Yes"
    When I follow "Edit"
    And I fill in "First name" with "Alpha"
    And I fill in "Middle name" with "Beta"
    And I fill in "Last name" with "Gamma"
    And I fill in "Net" with "also_fake"
    And I fill in "Email" with "jd2@example.com"
    And I fill in "Mobile phone" with "607-555-1200"
    And I fill in "Work phone" with "607-555-1200"
    And I fill in "Home phone" with "607-555-4300"
    And I fill in "Work address" with "200 Day Hall"
    And I fill in "Date of birth" with "1982-07-10"
    And I attach a file named "resume.pdf" of 1 kilobyte to "Resume"
    And I choose "No"
    And I choose "undergrad"
    And I press "Update"
    Then I should see "User was successfully updated."
    And I should see "First name: Alpha"
    And I should see "Middle name: Beta"
    And I should see "Last name: Gamma"
    And I should see "Net id: also_fake"
    And I should see "Email: jd2@example.com"
    And I should see "Mobile phone: (607) 555-1200"
    And I should see "Work phone: (607) 555-1200"
    And I should see "Home phone: (607) 555-4300"
    And I should see "Work address: 200 Day Hall"
    And I should see "Date of birth: July 10, 1982"
    And I should see "Resume? Yes"
    And I should see "Statuses: undergrad"
    And I should see "Administrator? No"

  Scenario: Delete user
    Given a user exists with first_name: "John", last_name: "Doe 4"
    And a user exists with first_name: "John", last_name: "Doe 3"
    And a user exists with first_name: "John", last_name: "Doe 2"
    And a user exists with first_name: "John", last_name: "Doe 1"
    And I log in as user: "admin"
    And I am on the users page
    When I fill in "Name" with "Doe 2"
    And I press "Search"
    Then I should see the following users:
      |Name        |
      |Doe 2, John |
    When I follow "Destroy" for the 4th user
    Then I should see the following users:
      |Name        |
      |Doe, John   |
      |Doe 1, John |
      |Doe 2, John |
      |Doe 4, John |

