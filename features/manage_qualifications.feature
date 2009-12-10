Feature: Manage qualifications
  In order to identify and track qualifications of users for various positions
  As an administrator
  I want to create, modify, delete, list, and show qualifications

  Scenario: Register new qualification
    Given I am on the new qualification page
    When I fill in "Name" with "Valuable skill"
    And I fill in "Description" with "This skill is useful for several things."
    And I press "Create"
    Then I should see "Qualification was successfully created."
    And I should see "Name: Valuable skill"
    And I should see "This skill is useful for several things."
    When I follow "Edit"
    And I fill in "Name" with "No longer valuable skill"
    And I fill in "Description" with "This skill is *not* useful for several things."
    And I press "Update"
    Then I should see "Qualification was successfully updated."
    And I should see "Name: No longer valuable skill"
    And I should see "This skill is not useful for several things."

  Scenario: Delete qualification
    Given a qualification exists with name: "qualification 4"
    And a qualification exists with name: "qualification 3"
    And a qualification exists with name: "qualification 2"
    And a qualification exists with name: "qualification 1"
    When I delete the 3rd qualification
    Then I should see the following qualifications:
      |Name           |
      |qualification 1|
      |qualification 2|
      |qualification 4|

