Feature: Home page
  In order to access key features
  As an authenticated user
  I want a dashboard on the home page

  Scenario Outline: View authorities
    Given an authorization scenario of an authority to which I have a <relationship> relationship
    When I am on the home page
    Then I should <see> the authority
    Examples:
      |relationship        |see    |
      |admin               |see    |
      |staff               |see    |
      |current authority   |see    |
      |current authority_ro|see    |
      |future authority    |see    |
      |future authority_ro |see    |
      |recent authority    |not see|
      |plain               |not see|

