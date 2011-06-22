Feature: Manage logos
  In order to define questionnaires for applicants
  As a customized application service
  I want to create, update, destroy, show, and list logos

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for logos controller actions
    Given a logo exists
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the logo
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the logos page
    Then I should <show> authorized
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New logo"
    Given I am on the new logo page
    Then I should <create> authorized
    Given I post on the logos page
    Then I should <create> authorized
    And I am on the edit page for the logo
    Then I should <update> authorized
    Given I put on the page for the logo
    Then I should <update> authorized
    Given I delete on the page for the logo
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new logo
    Given I log in as user: "admin"
    And I am on the new logo page
    When I fill in "Name" with "SA logo"
    And I attach the file "spec/assets/logo.eps" to "Vector"
    And I press "Create"
    Then I should see "Logo was successfully created."
    And I should see "Name: SA logo"
    When I follow "Edit"
    And I fill in "Name" with "GPSA logo"
    And I press "Update"
    Then I should see "Logo was successfully updated."
    And I should see "Name: GPSA logo"

  Scenario: Delete logo
    Given a logo exists with name: "logo 4"
    And a logo exists with name: "logo 3"
    And a logo exists with name: "logo 2"
    And a logo exists with name: "logo 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd logo
    Then I should see the following logos:
      |Name  |
      |logo 1|
      |logo 2|
      |logo 4|

