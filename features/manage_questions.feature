Feature: Manage questions
  In order to specify questions used in quizzes filled out in applications
  As an administrator
  I want to create, modify, destroy, list and show questions

  Scenario Outline: Test permissions for questions controller actions
    Given a question exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new question page
    Then I should <create>
    Given I post on the questions page
    Then I should <create>
    And I am on the edit page for the question
    Then I should <update>
    Given I put on the page for the question
    Then I should <update>
    Given I am on the page for the question
    Then I should <show>
    Given I am on the questions page
    Then I should <show>
    Given I delete on the page for the question
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | see "not authorized"     |

  Scenario: Register new question
    Given a quiz exists with name: "Colors"
    And a quiz exists with name: "Desserts"
    And I log in as the administrator
    And I am on the new question page
    When I fill in "Name" with "Favorite color"
    And I fill in "Content" with "What is your favorite color?"
    And I select "Text Box" from "Disposition"
    And I choose "question_global_true"
    And I check "Colors"
    And I press "Create"
    Then I should see "Question was successfully created."
    And I should see "Name: Favorite color"
    And I should see "What is your favorite color?"
    And I should see "Disposition: Text Box"
    And I should see "Global? Yes"
    And I should see "Colors"
    And I should not see "Desserts"
    When I follow "Edit"
    And I fill in "Name" with "Favorite dessert"
    And I fill in "Content" with "What is your favorite *dessert*?"
    And I select "Yes/No" from "Disposition"
    And I uncheck "Colors"
    And I check "Desserts"
    And I choose "question_global_false"
    And I press "Update"
    Then I should see "Question was successfully updated."
    And I should see "Name: Favorite dessert"
    And I should see "What is your favorite dessert?"
    And I should see "Disposition: Yes/No"
    And I should see "Global? No"
    And I should see "Desserts"
    And I should not see "Colors"

  Scenario: List questions for a quiz
    Given a quiz: "colors" exists with name: "Colors"
    And a question exists with name: "Color question"
    And the question is amongst the questions of the quiz
    And question exists with name: "Another question"
    And I log in as the administrator
    When I am on the questions page
    Then I should see the following questions:
      | Name             |
      | Another question |
      | Color question   |
    When I am on the questions page for quiz: "colors"
    Then I should see the following questions:
      | Name           |
      | Color question |

  Scenario: Delete question
    Given a question exists with name: "question 4"
    And a question exists with name: "question 3"
    And a question exists with name: "question 2"
    And a question exists with name: "question 1"
    And I log in as the administrator
    When I delete the 3rd question
    Then I should see the following questions:
      |Name      |
      |question 1|
      |question 2|
      |question 4|

