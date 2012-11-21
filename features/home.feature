Feature: Home page
  In order to access key features
  As an authenticated user
  I want a dashboard on the home page

  Scenario Outline: List my authorities
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

  Scenario Outline: List in process motions
    Given an authorization scenario of published, <state> motion of sponsored origin to which I have a <relationship> relationship
    When I am on the home page
    Then I should <see> the motion
    Examples:
      |relationship   |state    |see    |
      |admin          |started  |not see|
      |current sponsor|started  |see    |
      |current sponsor|rejected |not see|
      |current voter  |started  |not see|
      |past sponsor   |started  |not see|

