@wip
Feature: Manage qualifications
  In order to identify and track qualifications of users for various positions
  As an administrator
  I want to create, modify, delete, list, and show qualifications

  Scenario Outline: Test permissions for qualifications controller actions
    Given a qualification exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new qualification page
    Then I should <create>
    Given I post on the qualifications page
    Then I should <create>
    And I am on the edit page for the qualification
    Then I should <update>
    Given I put on the page for the qualification
    Then I should <update>
    Given I am on the page for the qualification
    Then I should <show>
    Given I am on the qualifications page
    Then I should <show>
    Given I delete on the page for the qualification
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | not see "not authorized" |

  Scenario: Register new qualification
    Given I log in as the administrator
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
    And I log in as the administrator
    When I delete the 3rd qualification
    Then I should see the following qualifications:
      |Name           |
      |qualification 1|
      |qualification 2|
      |qualification 4|

