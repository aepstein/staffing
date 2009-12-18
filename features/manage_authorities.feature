Feature: Manage authorities
  In order to identify and enable groups to manage committee membership
  As an administrator
  I want to create, edit, list, delete, and show authorities

  Scenario: Register new authority and edit
    Given I am on the new authority page
    When I fill in "Name" with "Supreme Authority"
    And I fill in "Join message" with "Welcome to *committee*."
    And I fill in "Leave message" with "You were *dropped* from the committee."
    And I press "Create"
    Then I should see "Authority was successfully created."
    And I should see "Name: Supreme Authority"
    And I should see "Welcome to committee."
    And I should see "You were dropped from the committee."
    When I follow "Edit"
    And I fill in "Name" with "Subordinate Authority"
    And I fill in "Join message" with "Welcome message"
    And I fill in "Leave message" with "Farewell message"
    And I press "Update"
    Then I should see "Authority was successfully updated."
    And I should see "Name: Subordinate Authority"
    And I should see "Welcome message"
    And I should see "Farewell message"

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

