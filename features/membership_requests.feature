Feature: Membership requests
  In order to receive and process requests for membership
  As an applicant, committee authority member or administrator
  I want to create, modify, list, show, and destroy requests for membership

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

Scenario Outline: Access control to reactivate
  Given an authorization scenario of a current membership_request to which I have a <relation> relationship
  And the membership_request is rejected
  Then I <reactivate> reactivate the membership_request
  Examples:
    |relation            |reactivate|
    |admin               |may       |
    |staff               |may       |
    |current authority   |may       |
    |current authority_ro|may not   |
    |recent authority    |may not   |
    |future authority    |may       |
    |plain               |may not   |

Scenario Outline: Create and edit request
  Given I log in as the plain user
  And I have an undergrad status
  And <status> may create membership_requests for the committee
  When I create a membership_request for the committee
  Then I should see the new membership_request
  When I update the membership_request
  Then I should see the updated membership_request
  Examples:
    |status      |
    |an undergrad|
    |everyone    |

Scenario: Move a request to a different priority
  Given there are 4 membership_requests with a common user
  When I move the 3rd membership_request to the position of the 1st membership_request
  Then the membership_requests should have the following positions:
    |2|
    |3|
    |1|
    |4|

Scenario Outline: Fail to create request
  Given I log in as the plain user
  And I have an undergrad status
  And <status> may create membership_requests for the committee
  Then I may not create membership_requests for the committee
  Examples:
    |status|
    |a grad|
    |noone |

Scenario Outline: Reject a request and reactivate
  Given an authorization scenario of a current membership_request to which I have a <relation> relationship
  When I reject the membership_request
  Then I should see the rejected membership_request
  When I reactivate the membership_request
  Then I should see the reactivated membership_request
  Examples:
    |relation          |
    |staff             |
    |current authority |

Scenario Outline: Reapply on a rejected request
  Given an authorization scenario of a current membership_request to which I have a <relation> relationship
  And the membership_request is rejected
  When I touch the membership_request
  Then the membership_request should be active
  Examples:
    |relation |
    |staff    |
    |requestor|

Scenario Outline: Search for membership_requests
  Given I log in as the staff user
  And there are 4 membership_requests with a common <common>
  When I search for the <attribute> of the 1st membership_request
  Then I should not see the search field for a <common>
  And I should only find the 1st membership_request
  Examples:
    |common   |attribute|
    |user     |committee|
    |committee|user     |

Scenario: List/delete a membership_requests by last name
  Given I log in as the admin user
  And there are 4 membership_requests for a committee by last
  And I "Destroy" the 3rd membership_request for the committee
  Then I should see the following membership_requests for the committee:
    |John Doe10001|
    |John Doe10002|
    |John Doe10004|

Scenario: List a membership_requests by first name
  Given I log in as the staff user
  And there are 4 membership_requests for a committee by first
  Then I should see the following membership_requests for the committee:
    |John10001 Doe|
    |John10002 Doe|
    |John10003 Doe|
    |John10004 Doe|

