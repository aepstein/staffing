Feature: Manage authorities
  In order to identify and enable groups to manage committee membership
  As an administrator
  I want to create, edit, list, delete, and show authorities

  Scenario: Register new authority and edit
    Given I am on the new authority page
    When I fill in "Name" with "Supreme Authority"
    And I press "Create"
    Then I should see "Authority was successfully created."
    And I should see "Name: Supreme Authority"
    When I follow "Edit"
    And I fill in "Name" with "Subordinate Authority"
    And I press "Update"
    Then I should see "Authority was successfully updated."
    And I should see "Name: Subordinate Authority"

  Scenario: Delete authority
    Given an authority exists with name: "authority 4"
    And an authority exists with name: "authority 3"
    And an authority exists with name: "authority 2"
    And an authority exists with name: "authority 1"
    When I delete the 3rd authority
    Then I should see the following authorities:
      |Name       |
      |authority 1|
      |authority 2|
      |authority 4|

