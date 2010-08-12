Feature: Manage quizzes
  In order to define questionnaires for applicants
  As a customized application service
  I want to create, update, destroy, show, and list quizzes

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for quizzes controller actions
    Given a quiz exists
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the quiz
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the quizzes page
    Then I should <show> authorized
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New quiz"
    Given I am on the new quiz page
    Then I should <create> authorized
    Given I post on the quizzes page
    Then I should <create> authorized
    And I am on the edit page for the quiz
    Then I should <update> authorized
    Given I put on the page for the quiz
    Then I should <update> authorized
    Given I delete on the page for the quiz
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | not see |

  Scenario: Register new quiz
    Given I log in as user: "admin"
    And I am on the new quiz page
    When I fill in "Name" with "SA questionnaire"
    And I press "Create"
    Then I should see "Quiz was successfully created."
    And I should see "Name: SA questionnaire"
    When I follow "Edit"
    And I fill in "Name" with "GPSA questionnaire"
    And I press "Update"
    Then I should see "Quiz was successfully updated."
    And I should see "Name: GPSA questionnaire"

  Scenario: Delete quiz
    Given a quiz exists with name: "quiz 4"
    And a quiz exists with name: "quiz 3"
    And a quiz exists with name: "quiz 2"
    And a quiz exists with name: "quiz 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd quiz
    Then I should see the following quizzes:
      |Name  |
      |quiz 1|
      |quiz 2|
      |quiz 4|

