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
    And a question: "first" exists with name: "Favorite color", content: "What is your favorite color?", format: "string"
    And a question: "second" exists with name: "Capital of Assyria", content: "What is the capital of Assyria?", format: "text"
    And a question: "third" exists with name: "Qualified", content: "Are you qualified?", format: "boolean"
    And question: "first" is amongst the questions of quiz: "generic"
    And question: "second" is amongst the questions of quiz: "generic"
    And question: "third" is amongst the questions of quiz: "generic"
    And a position: "popular" exists with name: "Most Popular Person", schedule: schedule "annual", quiz: quiz "generic"
    And a position: "unpopular" exists with name: "Least Popular Person"

  Scenario Outline: Test permissions for requests controller actions
    Given a request exists with requestable: the position, user: user "applicant", state: "<state>"
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
    Then I should <index>
    Given I delete on the page for the request
    Then I should <destroy>
    Examples:
      | state     | user      | index                    | create                   | update                   | destroy                  | show                     |
      | started   | admin     | see "Williams, Bill"     | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | started   | applicant | see "Williams, Bill"     | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | completed | applicant | see "Williams, Bill"     | not see "not authorized" | see "not authorized"     | see "not authorized"     | not see "not authorized" |
      | started   | regular   | not see "Williams, Bill" | not see "not authorized" | see "not authorized"     | see "not authorized"     | see "not authorized"     |

  Scenario Outline: Register new request or edit
    Given I log in as "applicant" with password "secret"
    And a committee exists with name: "Central Committee"
    And an enrollment exists with committee: the committee, position: position "popular"
    And a request exists with user: user "applicant", requestable: position "unpopular"
    And I am on the new request page for <requestable>
    When I fill in "Desired Start Date" with "2008-06-01"
    And I fill in "Desired End Date" with "2009-05-31"
    And I fill in "Favorite color" with "*bl*ue"
    And I fill in "Capital of Assyria" with "*Da*mascus"
    And I choose "Yes"
    And I select "Least Popular Person" from "Move to"
    And I press "Create"
    Then I should see "Request was successfully created."
    And I should see "Requestable: <name>"
    And I should see "User: Bill Williams"
    And I should see "State: started"
    And I should see "blue"
    And I should see "Damascus"
    And I should see "Are you qualified? Yes"
    And I should see "Resume? No"
    When I follow "Edit"
    And I fill in "Desired Start Date" with "2009-06-01"
    And I fill in "Desired End Date" with "2010-05-31"
    And fill in "Favorite color" with "yellow"
    And fill in "Capital of Assyria" with "Assur"
    And I choose "No"
    And I attach a file of type "application/pdf" and 1 kilobyte to "Resume"
    And I press "Update"
    Then I should see "Request was successfully updated."
    And I should see "Requestable: <name>"
    And I should see "User: Bill Williams"
    And I should see "State: started"
    And I should see "yellow"
    And I should see "Assur"
    And I should see "Are you qualified? No"
    And I should see "Resume? Yes"
    When I am on the requests page for user: "applicant"
    Then I should see the following requests:
      | Requestable          |
      | <name>               |
      | Least Popular Person |
    Examples:
      | requestable         | name                |
      | the committee       | Central Committee   |
      | position: "popular" | Most Popular Person |

  Scenario: Delete request
    Given a user: "applicant1" exists with last_name: "Doe 1", first_name: "John"
    And a user: "applicant2" exists with last_name: "Doe 2", first_name: "John"
    And a user: "applicant3" exists with last_name: "Doe 3", first_name: "John"
    And a user: "applicant4" exists with last_name: "Doe 4", first_name: "John"
    And a request exists with requestable: position "popular", user: user "applicant4"
    And a request exists with requestable: position "popular", user: user "applicant3"
    And a request exists with requestable: position "popular", user: user "applicant2"
    And a request exists with requestable: position "popular", user: user "applicant1"
    And I log in as the administrator
    When I delete the 3rd request for position: "popular"
    Then I should see the following requests:
      |User        |
      |Doe 1, John |
      |Doe 2, John |
      |Doe 4, John |

