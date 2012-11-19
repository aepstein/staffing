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
    And a requestable_committee exists with schedule: schedule "annual"
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

