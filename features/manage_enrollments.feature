Feature: Manage enrollments
  In order to specify what rolls a position confers
  As an administrator
  I want to create, modify, list, show, and destroy enrollments

  Background:
    Given a position: "member" exists with name: "Member of Committee"
    And a position: "ex-officio" exists with name: "Ex-Officio Member of Committee"
    And a committee: "committee" exists with name: "Favorite Committee"

  Scenario: Register new enrollment
    Given I log in as the administrator
    And I am on the new enrollment page for committee: "committee"
    When I select "Member of Committee" from "Position"
    And I fill in "Title" with "Voting Member"
    And I fill in "Votes" with "1"
    And I press "Create"
    Then I should see "Enrollment was successfully created."
    And I should see "Position: Member of Committee"
    And I should see "Committee: Favorite Committee"
    And I should see "Title: Voting Member"
    And I should see "Votes: 1"
    When I follow "Edit"
    And I select "Ex-Officio Member of Committee" from "Position"
    And I fill in "Title" with "Non-Voting Member"
    And I fill in "Votes" with "0"
    And I press "Update"
    Then I should see "Enrollment was successfully updated."
    And I should see "Position: Ex-Officio Member of Committee"
    And I should see "Committee: Favorite Committee"
    And I should see "Title: Non-Voting Member"
    And I should see "Votes: 0"

  Scenario: Delete enrollment
    Given a position: "position4" exists with name: "position 4"
    And a position: "position3" exists with name: "position 3"
    And a position: "position2" exists with name: "position 2"
    And a position: "position1" exists with name: "position 1"
    And an enrollment: "enrollment4" exists with title: "class 2", committee: committee "committee", position: position "position2"
    And an enrollment: "enrollment3" exists with title: "class 2", committee: committee "committee", position: position "position1"
    And an enrollment: "enrollment2" exists with title: "class 1", committee: committee "committee", position: position "position4"
    And an enrollment: "enrollment1" exists with title: "class 1", committee: committee "committee", position: position "position3"
    When I delete the 3rd enrollment for committee: "committee"
    Then I should see the following enrollments:
      |Position  |Title       |Votes  |
      |position 3|class 1     |1      |
      |position 4|class 1     |1      |
      |position 2|class 2     |1      |
