Feature: Manage questions
  In order to record questions to associate with quizzes for committee membership
  As an administrator
  I want to create, modify, list, show, and destroy questions

Scenario Outline: Access control
  Given an authorization scenario of a question to which I have a <role> relationship
  Then I <show> see the question
  And I <create> create questions
  And I <update> update the question
  And I <destroy> destroy the question
  Examples:
    |role |show   |create |update |destroy|
    |admin|may    |may    |may    |may    |
    |staff|may    |may    |may    |may not|
    |plain|may not|may not|may not|may not|

Scenario: Create/edit a question
  Given I log in as the staff user
  When I create a question
  Then I should see the new question
  When I update the question
  Then I should see the edited question

Scenario: Search questions
  Given I log in as the staff user
  And there are 4 questions
  And I search for questions with name "2"
  Then I should see the following questions:
    | Question 2 |
  Given I search for questions with content "13"
  Then I should see the following questions:
    | Question 2 |

Scenario: List/delete a question
  Given I log in as the admin user
  And there are 4 questions
  And I "Destroy" the 3rd question
  Then I should see the following questions:
  | Question 1 |
  | Question 2 |
  | Question 4 |

