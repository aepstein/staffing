Feature: Manage requests
  In order to represent applications for membership in committees
  As a user or reviewier
  I want to create, modify, list, show, and destroy requests

  Background:
    Given a user: "applicant" exists with first_name: "Bill", last_name: "Williams"
    And a schedule: "annual" exists with name: "Annual"
    And a period: "2008" exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a period: "2009" exists with schedule: schedule "annual", starts_at: "2009-06-01", ends_at: "2010-05-31"
    And a quiz: "generic" exists with name: "Generic Questionnaire"
    And a question: "first" exists with name: "Favorite color", content: "What is your favorite color?", disposition: "string"
    And a question: "second" exists with name: "Capital of Assyria", content: "What is the capital of Assyria?", disposition: "text"
    And a question: "third" exists with name: "Qualified", content: "Are you qualified?", disposition: "boolean"
    And question: "first" is amongst the questions of quiz: "generic"
    And question: "second" is amongst the questions of quiz: "generic"
    And question: "third" is amongst the questions of quiz: "generic"
    And a user: "admin" exists with admin: true, first_name: "Mister", last_name: "Administrator"

  Scenario Outline: Test permissions for requests controller actions
    Given a committee: "authority" exists
    And an authority exists with committee: committee "authority"
    And a position: "authority" exists with authority: the authority
    And an enrollment exists with position: position "authority", committee: committee "authority"
    And a user: "authority" exists
    And a membership exists with user: user "authority", position: position "authority"
    And a position: "authority_ro" exists with authority: the authority
    And an enrollment exists with position: position "authority_ro", committee: committee "authority", votes: 0
    And a user: "authority_ro" exists
    And a membership exists with user: user "authority_ro", position: position: "authority_ro"
    And a position: "requestable" exists with authority: the authority
    And a committee: "requestable" exists
    And a committee: "expired_requestable" exists
    And an enrollment exists with position: position "requestable", committee: committee "requestable", requestable: true
    And an enrollment exists with position: position "requestable", committee: committee "expired_requestable", requestable: true
    And a request: "focus" exists with committee: committee "requestable", user: user "applicant"
    And an expired_request: "committee" exists with committee: committee "expired_requestable", user: user "applicant"
    And a user: "regular" exists with admin: false
    And I log in as user: "<user>"
    And I am on the new request page for committee: "requestable"
    Then I should <create> authorized
    Given I post on the requests page for committee: "requestable"
    Then I should <create> authorized
    And I am on the edit page for request: "focus"
    Then I should <update> authorized
    Given I put on the page for request: "focus"
    Then I should <update> authorized
    Given I am on the page for request: "focus"
    Then I should <show> authorized
    Given I am on the requests page for committee: "requestable"
    Then I should <show> "Williams, Bill"
    Given I am on the requests page for committee: "expired_requestable"
    Then I should <show> "Williams, Bill"
    Given I am on the requests page for the authority
    Then I should <show> "Williams, Bill"
    And I should <reject> "Reject"
    Given I am on the expired requests page for committee: "requestable"
    Then I should not see "Williams, Bill"
    Given I am on the unexpired requests page for committee: "requestable"
    Then I should <show> "Williams, Bill"
    Given I am on the rejected requests page for committee: "requestable"
    Then I should not see "Williams, Bill"
    Given I am on the active requests page for committee: "requestable"
    Then I should <show> "Williams, Bill"
    Given I am on the expired requests page for committee: "expired_requestable"
    Then I should <show> "Williams, Bill"
    Given I am on the unexpired requests page for committee: "expired_requestable"
    Then I should not see "Williams, Bill"
    Given I am on the rejected requests page for committee: "expired_requestable"
    Then I should not see "Williams, Bill"
    Given I am on the active requests page for committee: "expired_requestable"
    Then I should not see "Williams, Bill"
    Given I am on the reject page for request: "focus"
    Then I should <reject> authorized
    Given I put on the do_reject page for request: "focus"
    Then I should <reject> authorized
    Given I put on the reactivate page for request: "focus"
    Then I should <reject> authorized
    Given I delete on the page for request: "focus"
    Then I should <destroy> authorized
    Examples:
      | user         | show    | create  | update  | destroy | reject  |
      | admin        | see     | see     | see     | see     | see     |
      | applicant    | see     | see     | see     | see     | not see |
      | authority    | see     | see     | not see | not see | see     |
      | authority_ro | see     | see     | not see | not see | not see |
      | regular      | not see | see     | not see | not see | not see |

  Scenario Outline: Register new request or edit
    Given a position: "popular" exists with name: "Most Popular Person", schedule: schedule "annual", quiz: quiz "generic", renewable: true
    And a position: "unpopular" exists with name: "Least Popular Person", quiz: quiz "generic"
    And a position: "misc" exists with name: "Zee Last Position", quiz: quiz "generic"
    And a membership exists with position: position "popular", user: user "applicant", period: period "2008"
    And a committee: "focus" exists with name: "Central Committee"
    And a requestable_committee: "other" exists with name: "Least Popular"
    And an enrollment exists with committee: the committee, position: position "popular", requestable: true
    And a request exists with user: user "applicant", committee: committee "<existing>"
    And I log in as user: "applicant"
    And I am on the new request page for the committee: "focus"
    When I fill in "Desired Start Date" with "2008-06-01"
    And I fill in "Desired End Date" with "2009-05-31"
    And I fill in "Favorite color" with "*bl*ue"
    And I fill in "Capital of Assyria" with "*Da*mascus"
    And I choose "Yes"
    And I select "Least Popular Person" from "Move to"
    And I press "<button>"
    Then I should see "Request was successfully <sta>ated."
    And I should see "Committee: Central Committee"
    And I should see "User: Bill Williams"
    And I should see "blue"
    And I should see "Damascus"
    And I should see "Are you qualified? Yes"
    And I should see "Resume? No"
    And I should not see "Rejected at"
    And I should not see "Rejection comment"
    And I should not see "Rejection notice sent at"
    When I follow "Edit"
    And I fill in "Desired Start Date" with "2009-06-01"
    And I fill in "Desired End Date" with "2010-05-31"
    And fill in "Favorite color" with "yellow"
    And fill in "Capital of Assyria" with "Assur"
    And I choose "No"
    And I attach a file named "resume.pdf" of 1 kilobyte to "Resume"
    And I press "Update"
    Then I should see "Request was successfully updated."
    And I should see "Committee: Central Committee"
    And I should see "User: Bill Williams"
    And I should see "yellow"
    And I should see "Assur"
    And I should see "Are you qualified? No"
    And I should see "Resume? Yes"
    Examples:
      |existing          |button|sta|
      |committee "other" |Create|cre|
      |committee "focus" |Update|upd|

  Scenario: Reject a request and reactivate
    Given an authority exists with name: "Primary"
    And a position exists with authority: the authority
    And a committee exists
    And an enrollment exists with position: the position, committee: the committee, requestable: true
    And a request exists with committee: the committee
    And I log in as user: "admin"
    And I am on the reject page for the request
    And I select "Primary" from "Authority"
    And I fill in "Rejection comment" with "You are *not* qualified for the position."
    And I press "Update"
    Then I should see "Request was successfully rejected."
    And I should see "Rejected at"
    And I should see "Rejected by authority: Primary"
    And I should see "Rejected by user: Mister Administrator"
    And I should see "You are not qualified for the position."
    And I should see "Reject notice at: None sent."
    Given I put on the reactivate page for the request
    Then I should see "Request was successfully reactivated."
    And I should not see "Rejected at"

  Scenario: Reject a request and reapply
    Given an authority exists with name: "Primary"
    And a position exists with authority: the authority, quiz: quiz "generic"
    And a committee exists
    And an enrollment exists with position: the position, committee: the committee, requestable: true
    And a request exists with committee: the committee, user: user "applicant"
    And an answer exists with request: the request, question: question "first", content: "blue"
    And an answer exists with request: the request, question: question "second", content: "Damascus"
    And I log in as user: "admin"
    And I am on the page for the request
    Then I should see "What is your favorite color?"
    And I should see "blue"
    And I should see "What is the capital of Assyria?"
    And I should see "Damascus"
    Given question: "first" is alone amongst the questions of quiz: "generic"
    And I am on the reject page for the request
    And I select "Primary" from "Authority"
    And I fill in "Rejection comment" with "You are *not* qualified for the position."
    And I press "Update"
    Then I should see "Request was successfully rejected."
    And I should see "Rejected at"
    And I should see "Rejected by authority: Primary"
    And I should see "Rejected by user: Mister Administrator"
    And I should see "You are not qualified for the position."
    And I should see "Reject notice at: None sent."
    Given I log out
    And I log in as user: "applicant"
    And I am on the edit page for the request
    Then I should not see "What is the capital of Assyria?"
    And I should see "What is your favorite color?"
    And I press "Update"
    Then I should see "Request was successfully updated."
    Given quiz: "generic" has no questions
    And I am on the page for the request
    Then I should not see "blue"
    And I should not see "Damascus"
    And I should see "Status: active"

  Scenario: Delete request
    Given a user: "applicant1" exists with last_name: "Doe 1", first_name: "John"
    And a user: "applicant2" exists with last_name: "Doe 2", first_name: "John"
    And a user: "applicant3" exists with last_name: "Doe 3", first_name: "John"
    And a user: "applicant4" exists with last_name: "Doe 4", first_name: "John"
    And a requestable_committee exists with schedule: schedule "annual", quiz: quiz "generic"
    And a request exists with committee: the committee, user: user "applicant4"
    And a request exists with committee: the committee, user: user "applicant3"
    And a request exists with committee: the committee, user: user "applicant2"
    And a request exists with committee: the committee, user: user "applicant1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd request for the committee
    Then I should see the following requests:
      |User        |
      |Doe 1, John |
      |Doe 2, John |
      |Doe 4, John |

