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

