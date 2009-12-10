Feature: Manage questions
  In order to specify questions used in quizzes filled out in applications
  As an administrator
  I want to create, modify, destroy, list and show questions

  Scenario: Register new question
    Given I am on the new question page
    When I fill in "Name" with "Favorite color"
    And I fill in "Content" with "What is your favorite color?"
    And I choose "question_global_true"
    And I press "Create"
    Then I should see "Question was successfully created."
    And I should see "Name: Favorite color"
    And I should see "What is your favorite color?"
    And I should see "Global? Yes"
    When I follow "Edit"
    And I fill in "Name" with "Favorite dessert"
    And I fill in "Content" with "What is your favorite *dessert*?"
    And I choose "question_global_false"
    And I press "Update"
    Then I should see "Question was successfully updated."
    And I should see "Name: Favorite dessert"
    And I should see "What is your favorite dessert?"
    And I should see "Global? No"

  Scenario: Delete question
    Given a question exists with name: "question 4"
    And a question exists with name: "question 3"
    And a question exists with name: "question 2"
    And a question exists with name: "question 1"
    When I delete the 3rd question
    Then I should see the following questions:
      |Name      |
      |question 1|
      |question 2|
      |question 4|

