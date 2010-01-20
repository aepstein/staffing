Feature: Manage quizzes
  In order to define questionnaires for applicants
  As a customized application service
  I want to create, update, destroy, show, and list quizzes

  Scenario Outline: Test permissions for quizzes controller actions
    Given a quiz exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new quiz page
    Then I should <create>
    Given I post on the quizzes page
    Then I should <create>
    And I am on the edit page for the quiz
    Then I should <update>
    Given I put on the page for the quiz
    Then I should <update>
    Given I am on the page for the quiz
    Then I should <show>
    Given I am on the quizzes page
    Then I should <show>
    Given I delete on the page for the quiz
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | see "not authorized"     |

  Scenario: Register new quiz
    Given I log in as the administrator
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
    And I log in as the administrator
    When I delete the 3rd quiz
    Then I should see the following quizzes:
      |Name  |
      |quiz 1|
      |quiz 2|
      |quiz 4|

