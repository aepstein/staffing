Feature: Membership requests
  In order to receive and process requests for membership
  As an applicant, committee authority member or administrator
  I want to create, modify, list, show, and destroy requests for membership
@wip
Scenario Outline: Access control
  Given an authorization scenario of a current membership_request to which I have a <relation> relationship
  Then I <show> see the membership_request
  And I <update> update the membership_request
  And I <reject> reject the membership_request
  And I <destroy> destroy the membership_request
  Examples:
|relation            |show   |update |reject |destroy|
|admin               |may    |may    |may    |may    |
|staff               |may    |may    |may    |may not|
|current authority   |may    |may not|may    |may not|
|current authority_ro|may    |may not|may not|may not|
|recent authority    |may not|may not|may not|may not|
|future authority    |may    |may not|may    |may not|
|plain               |may not|may not|may not|may not|

Scenario: Access control to create requests
  Given an authorization scenario of a current membership_request to which I have a plain relationship
  Then I may create membership_requests for the committee

