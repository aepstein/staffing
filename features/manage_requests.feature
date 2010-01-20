@wip
Feature: Manage requests
  In order to represent applications for membership in committees
  As a user or reviewier
  I want to create, modify, list, show, and destroy requests

  Background:
    Given a user: "applicant" exists with net_id: "applicant", password: "secret", first_name: "Bill", last_name: "Williams"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a quiz: "generic" exists with name: "Generic Questionnaire"
    And a question: "first" exists with name: "Favorite color", content: "What is your favorite color?"
    And a question: "second" exists with name: "Capital of Assyria", content: "What is the capital of Assyria?"
    And question: "first" is amongst the questions of quiz: "generic"
    And question: "second" is amongst the questions of quiz: "generic"
    And a position: "popular" exists with name: "Most Popular Person", schedule: schedule "annual", quiz: quiz "generic"

  Scenario Outline: Test permissions for quizzes controller actions
    Given a request exists with position: the position
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new request page for the position
    Then I should <create>
    Given I post on the requests page for the position
    Then I should <create>
    And I am on the edit page for the request
    Then I should <update>
    Given I put on the page for the request
    Then I should <update>
    Given I am on the page for the request
    Then I should <show>
    Given I am on the requests page for the position
    Then I should <show>
    Given I delete on the page for the request
    Then I should <destroy>
    Examples:
      | state     | user    | create                   | update                   | destroy                  | show                     |
      | started   | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | started   | owner   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | completed | owner   | not see "not authorized" | see "not authorized"     | see "not authorized"     | not see "not authorized" |
      | started   | regular | not see "not authorized" | see "not authorized"     | see "not authorized"     | see "not authorized"     |

  Scenario: Register new request or edit
    Given I log in as "applicant" with password "secret"
    And I am on the new request page for position: "popular"
    When I check "1 Jun 2008 - 31 May 2009"
    And I fill in "Favorite color" with "*bl*ue"
    And I fill in "Capital of Assyria" with "*Da*mascus"
    And I press "Create"
    Then I should see "Request was successfully created."
    And I should see "Position: Most Popular Person"
    And I should see "User: Bill Williams"
    And I should see "State: started"
    And I should see "blue"
    And I should see "Damascus"
    And I should see the following periods:
      |Starts at  |Ends at     |
      |1 Jun 2008 |31 May 2009 |
    When I follow "Edit"
    And fill in "Favorite color" with "yellow"
    And fill in "Capital of Assyria" with "Assur"
    And I check "1 Jun 2009 - 31 May 2010"
    And I press "Update"
    Then I should see "Request was successfully updated."
    And I should see "Position: Most Popular Person"
    And I should see "User: Bill Williams"
    And I should see "State: started"
    And I should see "yellow"
    And I should see "Assur"
    And I should see the following periods:
      |Starts at  |Ends at     |
      |1 Jun 2009 |31 May 2010 |
      |1 Jun 2008 |31 May 2009 |
    When I follow "Edit"
    And I uncheck "1 Jun 2009 - 31 May 2010"
    And I press "Update"
    And I should see the following periods:
      |Starts at  |Ends at     |
      |1 Jun 2008 |31 May 2009 |

  Scenario: Delete request
    Given a user: "applicant1" exists with last_name: "Doe 1", first_name: "John"
    And a user: "applicant2" exists with last_name: "Doe 2", first_name: "John"
    And a user: "applicant3" exists with last_name: "Doe 3", first_name: "John"
    And a user: "applicant4" exists with last_name: "Doe 4", first_name: "John"
    And a request exists with position: position "popular", user: user "applicant4"
    And a request exists with position: position "popular", user: user "applicant3"
    And a request exists with position: position "popular", user: user "applicant2"
    And a request exists with position: position "popular", user: user "applicant1"
    And I log in as the administrator
    When I delete the 3rd request for position: "popular"
    Then I should see the following requests:
      |User        |
      |Doe 1, John |
      |Doe 2, John |
      |Doe 4, John |

