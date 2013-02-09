Feature: Manage quizzes
  In order to record quizzes to associate with positions and committees and periods for meetings, motions, and memberships
  As an administrator
  I want to create, modify, list, show, and destroy quizzes

Scenario Outline: Access control
  Given an authorization scenario of a quiz to which I have a <role> relationship
  Then I <show> see the quiz
  And I <create> create quizzes
  And I <update> update the quiz
  And I <destroy> destroy the quiz
  Examples:
    |role |show   |create |update |destroy|
    |admin|may    |may    |may    |may    |
    |staff|may    |may    |may    |may not|
    |plain|may not|may not|may not|may not|

@javascript
Scenario: Create/edit a quiz
  Given I log in as the staff user
  When I create a quiz
  Then I should see the new quiz
  When I update the quiz
  Then I should see the edited quiz

Scenario: Search quizzes
  Given I log in as the staff user
  And there are 4 quizzes
  And I search for quizzes with name "2"
  Then I should see the following quizzes:
  | Quiz 2 |

Scenario: List/delete a quiz
  Given I log in as the admin user
  And there are 4 quizzes
  And I "Destroy" the 3rd quiz
  Then I should see the following quizzes:
  | Quiz 1 |
  | Quiz 2 |
  | Quiz 4 |

