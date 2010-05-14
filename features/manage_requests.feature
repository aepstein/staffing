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

  Scenario Outline: Test permissions for requests controller actions
    Given a committee: "authority" exists
    And an authority exists with committee: committee "authority"
    And a position: "authority" exists with authority: the authority
    And an enrollment exists with position: position "authority", committee: committee "authority"
    And a user: "authority" exists with net_id: "authority", password: "secret", admin: false
    And a membership exists with user: user "authority", position: position "authority"
    And a position: "requestable" exists with authority: the authority
    And a committee: "requestable" exists
    And an enrollment exists with position: position "requestable", committee: committee "requestable"
    And a request: "focus" exists with requestable: position "requestable", user: user "applicant"
    And a request: "committee" exists with requestable: committee "requestable", user: user "applicant"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new request page for position: "requestable"
    Then I should <create> "not authorized"
    Given I post on the requests page for position: "requestable"
    Then I should <create> "not authorized"
    And I am on the edit page for request: "focus"
    Then I should <update> "not authorized"
    Given I put on the page for request: "focus"
    Then I should <update> "not authorized"
    Given I am on the page for request: "focus"
    Then I should <show> "not authorized"
    Given I am on the requests page for position: "requestable"
    Then I should <index> "Williams, Bill"
    Given I am on the requests page for committee: "requestable"
    Then I should <index> "Williams, Bill"
    Given I am on the requests page for the authority
    Then I should <index> "Williams, Bill"
    Given I delete on the page for request: "focus"
    Then I should <destroy> "not authorized"
    Examples:
      | user      | index   | create  | update  | destroy | show    |
      | admin     | see     | not see | not see | not see | not see |
      | applicant | see     | not see | not see | not see | not see |
      | authority | see     | not see | see     | see     | not see |
      | regular   | not see | not see | see     | see     | see     |

  Scenario Outline: Register new request or edit
    Given I log in as "applicant" with password "secret"
    And a position: "popular" exists with name: "Most Popular Person", schedule: schedule "annual", quiz: quiz "generic", renewable: true, requestable: <p_requestable>
    And a position: "unpopular" exists with name: "Least Popular Person", quiz: quiz "generic"
    And a position: "misc" exists with name: "Zee Last Position", quiz: quiz "generic"
    And a membership exists with position: position "popular", user: user "applicant", period: period "2008"
    And a committee exists with name: "Central Committee", requestable: true
    And an enrollment exists with committee: the committee, position: position "popular"
    And a request exists with user: user "applicant", requestable: <existing>
    And a request exists with user: user "applicant", requestable: position "unpopular"
    And I am on the new request page for <requestable>
    When I fill in "Desired Start Date" with "2008-06-01"
    And I fill in "Desired End Date" with "2009-05-31"
    And I fill in "Favorite color" with "*bl*ue"
    And I fill in "Capital of Assyria" with "*Da*mascus"
    And I choose "Yes"
    And I select "Least Popular Person" from "Move to"
    And I press "<button>"
    Then I should see "Request was successfully <sta>ated."
    And I should see "Requestable: <name>"
    And I should see "User: Bill Williams"
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
    And I should see "yellow"
    And I should see "Assur"
    And I should see "Are you qualified? No"
    And I should see "Resume? Yes"
    Examples:
      | requestable         | name                | p_requestable | existing             | button | sta |
      | the committee       | Central Committee   | true          | position "misc"      | Create | cre |
      | position: "popular" | Most Popular Person | true          | position "misc"      | Create | cre |
      | the membership      | Most Popular Person | true          | position "misc"      | Create | cre |
      | the membership      | Central Committee   | false         | position "misc"      | Create | cre |
      | the membership      | Most Popular Person | true          | position "popular"   | Update | upd |
      | the membership      | Central Committee   | false         | the committee        | Update | upd |
      | the committee       | Central Committee   | true          | the committee        | Update | upd |

  Scenario: Delete request
    Given a user: "applicant1" exists with last_name: "Doe 1", first_name: "John"
    And a user: "applicant2" exists with last_name: "Doe 2", first_name: "John"
    And a user: "applicant3" exists with last_name: "Doe 3", first_name: "John"
    And a user: "applicant4" exists with last_name: "Doe 4", first_name: "John"
    And a position: "popular" exists with name: "Most Popular Person", schedule: schedule "annual", quiz: quiz "generic"
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

