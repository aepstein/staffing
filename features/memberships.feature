Feature: Memberships
  In order to record memberships of people in positions
  As a committee authority member or administrator
  I want to create, modify, list, show, and destroy memberships

Scenario Outline: Access control
  Given an authorization scenario of a <member_tense> membership to which I have a <relation_tense> <relation> relationship
  Then I <show> see the membership
  And I <create> create memberships for the position
  And I <update> update the membership
  And I <destroy> destroy the membership
  Examples:
    |member_tense|relation_tense|relation    |show|create |update |destroy|
    |current     |current       |admin       |may |may    |may    |may    |
    |current     |current       |staff       |may |may    |may    |may not|
    |past        |current       |staff       |may |may    |may    |may not|
    |current     |current       |authority   |may |may    |may    |may not|
    |pending     |current       |authority   |may |may    |may    |may not|
    |recent      |current       |authority   |may |may    |may    |may not|
    |past        |current       |authority   |may |may    |may not|may not|
    |future      |current       |authority   |may |may    |may not|may not|
    |current     |current       |authority_ro|may |may not|may not|may not|
    |current     |current       |plain       |may |may not|may not|may not|

Scenario Outline: Access control to decline
  Given an authorization scenario of a <member_tense> membership to which I have a <relation_tense> <relation> relationship
  And the position <renewable> renewable
  And the member <requested> requested renewal to <request_tense>
  Then I <decline> decline the membership
  Examples:
    |member_tense|relation_tense|relation |renewable|requested|request_tense|decline|
    |historic    |current       |staff    |is       |has      |today        |may    |
    |historic    |current       |staff    |is not   |has      |today        |may not|
    |historic    |current       |staff    |is       |has not  |today        |may not|
    |historic    |current       |authority|is       |has      |today        |may    |
    |historic    |current       |authority|is not   |has      |today        |may not|
    |historic    |current       |authority|is       |has not  |today        |may not|
    |historic    |recent        |authority|is       |has      |next day     |may not|
    |past        |pending       |authority|is       |has      |today        |may not|
    |past        |pending       |authority|is       |has      |tomorrow     |may    |
    |past        |pending       |authority|is       |has      |next day     |may not|
    |current     |current       |authority|is       |has      |next day     |may not|
    |current     |future        |authority|is       |has      |next day     |may    |

Scenario Outline: Create/edit a membership
  When I attempt to create a <tense> membership as <relation_tense> <relation>
  Then I should not see the modifier error message
  And I should see the new membership
  When I update the membership
  Then I should see the edited membership
  Examples:
    |tense  |relation_tense|relation |
    |past   |current       |staff    |
    |current|current       |staff    |
    |future |current       |staff    |
    |current|current       |authority|
    |current|pending       |authority|
    |future |future        |authority|

Scenario Outline: Prevent authority from editing non-overlap membership
  When I attempt to create a <tense> membership as <relation_tense> <relation>
  Then I should <error> the modifier error message
  Examples:
    |tense  |relation_tense|relation |error  |
    |past   |current       |authority|see    |
    |future |current       |authority|see    |
    |pending|future        |authority|see    |
    |recent |current       |authority|not see|
    |pending|current       |authority|not see|
    |pending|pending       |authority|not see|

Scenario: List/delete a membership by last name
  Given I log in as the admin user
  And there are 4 memberships for a position by last
  And I "Destroy" the 3rd membership for the position
  Then I should see the following memberships for the position:
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John Doe10001|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John Doe10002|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John Doe10004|

Scenario: List/delete a membership by first name
  Given I log in as the admin user
  And there are 4 memberships for a position by first
  And I "Destroy" the 3rd membership for the position
  Then I should see the following memberships for the position:
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John10001 Doe|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John10002 Doe|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John10004 Doe|

Scenario: List/delete a membership by ends
  Given I log in as the admin user
  And there are 4 memberships for a position by end
  And I "Destroy" the 3rd membership for the position
  Then I should see the following memberships for the position:
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|30 Dec 2011|John Doe|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|29 Dec 2011|John Doe|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|27 Dec 2011|John Doe|

Scenario: List/delete a membership by starts
  Given I log in as the admin user
  And there are 4 memberships for a position by start
  And I "Destroy" the 3rd membership for the position
  Then I should see the following memberships for the position:
    |1 Jan 2011 - 31 Dec 2011|4 Jan 2011|31 Dec 2011|John Doe|
    |1 Jan 2011 - 31 Dec 2011|3 Jan 2011|31 Dec 2011|John Doe|
    |1 Jan 2011 - 31 Dec 2011|1 Jan 2011|31 Dec 2011|John Doe|

Scenario Outline: Access control to decline
  Given an authorization scenario of a past membership to which I have a current <relation> relationship
  And the position is renewable
  And the member has requested renewal to today
  When I decline the membership
  Then I should see the membership declined
  Examples:
    |relation |
    |staff    |
    |authority|

Scenario Outline: Show join and leave notices
  Given an authorization scenario of a past membership to which I have a current plain relationship
  When the <notice> notice has been sent
  Then I should see the <notice> notice is sent
  Examples:
    |notice|
    |join  |
    |leave |

Scenario Outline: Search for memberships
  Given I log in as the plain user
  And there are 4 memberships with a common <common>
  When I search for the <attribute> of the 1st membership
  Then I should not see the search field for a <common>
  And I should only find the 1st membership
  Examples:
  |common   |attribute|
  |user     |position |
  |user     |authority|
  |position |user     |
  |user     |committee|

