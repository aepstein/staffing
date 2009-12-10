Feature: Manage users
  In order to represent people in committees
  As an administrator
  I want to create, modify, list, show, and destroy users

  Scenario: Register new user and edit
    Given I log in as the administrator
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
    And I press "Create"
    Then I should see "User was successfully created."
    And I should see "First name: John"
    And I should see "Middle name: Nobody"
    And I should see "Last name: Doe"
    And I should see "Net id: fake"
    And I should see "Email: jd@example.com"
    And I should see "Mobile phone: 607-555-1212"
    And I should see "Work phone: 607-555-1234"
    And I should see "Home phone: 607-555-4321"
    And I should see "Work address: 100 Day Hall"
    And I should see "Date of birth: June  4, 1982"
    And I should see "Status: unknown"
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
    And I press "Update"
    Then I should see "User was successfully updated."
    And I should see "First name: Alpha"
    And I should see "Middle name: Beta"
    And I should see "Last name: Gamma"
    And I should see "Net id: also_fake"
    And I should see "Email: jd2@example.com"
    And I should see "Mobile phone: 607-555-1200"
    And I should see "Work phone: 607-555-1200"
    And I should see "Home phone: 607-555-4300"
    And I should see "Work address: 200 Day Hall"
    And I should see "Date of birth: July 10, 1982"
    And I should see "Status: unknown"

  Scenario: Delete user
    Given a user exists with first_name: "John", last_name: "Doe 4"
    And a user exists with first_name: "John", last_name: "Doe 3"
    And a user exists with first_name: "John", last_name: "Doe 2"
    And a user exists with first_name: "John", last_name: "Doe 1"
    And I log in as the administrator
    When I delete the 4th user
    Then I should see the following users:
      |Name        |
      |Doe, John   |
      |Doe 1, John |
      |Doe 2, John |
      |Doe 4, John |

