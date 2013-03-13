Feature: Membership requests
  In order to receive and process requests for membership
  As an applicant, committee authority member or administrator
  I want to create, modify, list, show, and destroy requests for membership

Scenario Outline: Access control
  Given an authorization scenario of a current membership request to which I have a <relation> relationship
  Then I <show> see the membership request
  And I <review> review the membership request
  And I <update> update the membership request
  And I <reject> reject the membership request
  And I <destroy> destroy the membership request
  Examples:
    |relation            |show   |review |update |reject |destroy|
    |admin               |may    |may not|may    |may    |may    |
    |staff               |may    |may not|may    |may    |may not|
    |current authority   |may    |may    |may not|may    |may not|
    |current authority_ro|may    |may    |may not|may not|may not|
    |recent authority    |may not|may not|may not|may not|may not|
    |pending authority   |may    |may    |may not|may    |may not|
    |future authority    |may    |may not|may not|may    |may not|
    |plain               |may not|may not|may not|may not|may not|

Scenario: Access control to create requests
  Given an authorization scenario of a current membership request to which I have a plain relationship
  Then I may create membership requests for the committee

Scenario Outline: Access control to reactivate
  Given an authorization scenario of a current membership request to which I have a <relation> relationship
  And the membership request is rejected
  Then I <reactivate> reactivate the membership request
  Examples:
    |relation            |reactivate|
    |admin               |may       |
    |staff               |may       |
    |current authority   |may       |
    |current authority_ro|may not   |
    |recent authority    |may not   |
    |future authority    |may       |
    |plain               |may not   |

@javascript
Scenario Outline: Create and edit request
  Given I log in as the plain user
  And I have an undergrad status
  And <status> may create membership requests for the committee
  When I create a membership request for the committee
  Then I should see the new membership request
  When I update the membership request
  Then I should see the updated membership request
  Examples:
    |status      |
    |an undergrad|
    |everyone    |

Scenario: Move a request to a different priority
  Given there are 4 membership requests with a common user
  When I move the 3rd membership request to the position of the 1st membership request
  Then the membership requests should have the following positions:
    |2|
    |3|
    |1|
    |4|

Scenario Outline: Fail to create request
  Given I log in as the plain user
  And I have an undergrad status
  And <status> may create membership requests for the committee
  Then I may not create membership requests for the committee
  Examples:
    |status|
    |a grad|
    |noone |

Scenario Outline: Reject a request and reactivate
  Given an authorization scenario of a current membership request to which I have a <relation> relationship
  When I reject the membership request
  Then I should see the rejected membership request
  When I reactivate the membership request
  Then I should see the reactivated membership request
  Examples:
    |relation          |
    |staff             |
    |current authority |

Scenario Outline: Reapply on a rejected request
  Given an authorization scenario of a current membership request to which I have a <relation> relationship
  And the membership request is rejected
  When I touch the membership request
  Then the membership request should be active
  Examples:
    |relation |
    |staff    |
    |requestor|

Scenario Outline: Search for membership requests
  Given I log in as the staff user
  And there are 4 membership requests with a common <common>
  When I search for the <attribute> of the 1st membership request
  Then I should not see the search field for a <common>
  And I should only find the 1st membership request
  Examples:
    |common   |attribute|
    |user     |committee|
    |committee|user     |

Scenario: List/delete membership requests by last name
  Given I log in as the admin user
  And there are 4 membership requests for a committee by last
  And I "Destroy" the 3rd membership request for the committee
  Then I should see the following membership requests for the committee:
    |John Doe10001|
    |John Doe10002|
    |John Doe10004|

Scenario: List membership requests by first name
  Given I log in as the staff user
  And there are 4 membership requests for a committee by first
  Then I should see the following membership requests for the committee:
    |John10001 Doe|
    |John10002 Doe|
    |John10003 Doe|
    |John10004 Doe|

