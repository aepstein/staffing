Feature: Home page
  In order to access key features
  As an authenticated user
  I want a dashboard on the home page

  Scenario Outline: List my active membership requests
    Given an authorization scenario of an <condition> membership request to which I have a <relationship> relationship
    When I am on the home page
    Then I should <see> membership_request in my active membership requests
    Examples:
    |condition       |relationship|see        |
    |current active  |admin       |not see any|
    |current active  |requestor   |see the    |
    |current rejected|requestor   |not see any|
    |expired active  |requestor   |not see any|

