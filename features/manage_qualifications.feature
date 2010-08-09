Feature: Manage qualifications
  In order to identify and track qualifications of users for various positions
  As an administrator
  I want to create, modify, delete, list, and show qualifications

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for qualifications controller actions
    Given a qualification exists with name: "Focus"
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as user: "<user>"
    Given I am on the page for the qualification
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the qualifications page
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New qualification"
    Given I am on the new qualification page
    Then I should <create> authorized
    Given I post on the qualifications page
    Then I should <create> authorized
    And I am on the edit page for the qualification
    Then I should <update> authorized
    Given I put on the page for the qualification
    Then I should <update> authorized
    Given I delete on the page for the qualification
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new qualification
    Given I log in as user: "admin"
    And I am on the new qualification page
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
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd qualification
    Then I should see the following qualifications:
      |Name           |
      |qualification 1|
      |qualification 2|
      |qualification 4|

