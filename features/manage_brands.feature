Feature: Manage brands
  In order to define questionnaires for applicants
  As a customized application service
  I want to create, update, destroy, show, and list brands

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for brands controller actions
    Given a brand exists
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the brand
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the brands page
    Then I should <show> authorized
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New brand"
    Given I am on the new brand page
    Then I should <create> authorized
    Given I post on the brands page
    Then I should <create> authorized
    And I am on the edit page for the brand
    Then I should <update> authorized
    Given I put on the page for the brand
    Then I should <update> authorized
    Given I delete on the page for the brand
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new brand
    Given I log in as user: "admin"
    And I am on the new brand page
    When I fill in "Name" with "SA brand"
    And I attach the file "spec/assets/brand.eps" to "Logo"
    And I press "Create"
    Then I should see "Brand was successfully created."
    And I should see "Name: SA brand"
    When I follow "Edit"
    And I fill in "Name" with "GPSA brand"
    And I press "Update"
    Then I should see "Brand was successfully updated."
    And I should see "Name: GPSA brand"

  Scenario: Delete brand
    Given a brand exists with name: "brand 4"
    And a brand exists with name: "brand 3"
    And a brand exists with name: "brand 2"
    And a brand exists with name: "brand 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd brand
    Then I should see the following brands:
      |Name  |
      |brand 1|
      |brand 2|
      |brand 4|

