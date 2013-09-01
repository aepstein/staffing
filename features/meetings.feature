Feature: Manage meetings
  In order to record meetings to associate with committees and motions
  As a staff member or committee member
  I want to create, modify, list, show, and destroy meetings

Scenario Outline: Access control
  Given a <tense> <pub>published meeting exists of a committee to which I have a <relationship> relationship
  Then I <show> see the meeting
  And I <create> create meetings
  And I <update> update the meeting
  And I <destroy> destroy the meeting
  Examples:
    |relationship    |pub|tense  |show   |create |update |destroy|
    |admin           |un |current|may    |may    |may    |may    |
    |admin           |un |past   |may    |may    |may    |may    |
    |admin           |un |future |may    |may    |may    |may    |
    |staff           |un |current|may    |may    |may    |may    |
    |staff           |un |past   |may    |may    |may    |may not|
    |staff           |un |future |may    |may    |may    |may    |
    |current chair   |un |current|may    |may    |may    |may    |
    |current chair   |un |recent |may    |may    |may    |may not|
    |current chair   |un |pending|may    |may    |may    |may    |
    |recent chair    |un |current|may    |may not|may not|may not|
    |recent chair    |un |pending|may not|may not|may not|may not|
    |pending chair   |un |current|may    |may not|may not|may not|
    |current voter   |un |current|may    |may not|may not|may not|
    |current voter   |un |pending|may not|may not|may not|may not|
    |pending voter   |un |pending|may not|may not|may not|may not|
    |current nonvoter|un |current|may    |may not|may not|may not|
    |current nonvoter|un |pending|may not|may not|may not|may not|
    |pending nonvoter|un |pending|may not|may not|may not|may not|
    |plain           |un |pending|may not|may not|may not|may not|
    |plain           |un |recent |may    |may not|may not|may not|
    |plain           |   |current|may    |may not|may not|may not|
    |plain           |   |pending|may    |may not|may not|may not|

@javascript
Scenario Outline: Create/edit a meeting
  When I create a meeting with a <item> item as <role>
  Then I should see the new meeting with the <item> item
  When I update the meeting
  Then I should see the edited meeting
  Examples:
    |item  |role |
    |named |staff|
    |motion|staff|
    |named |chair|
    |motion|chair|

Scenario: Search meetings
  Given I log in as the staff user
  And there are 4 meetings
  When I search for meetings with period "1 Jan 2003 - 31 Dec 2003"
  Then I should see the following meetings:
    |01 Jan 2003 09:00|

Scenario: List/delete a meeting
  Given I log in as the admin user
  And there are 4 meetings
  And I "Destroy" the 3rd meeting
  Then I should see the following meetings:
    |01 Jan 2004 09:00|
    |01 Jan 2003 09:00|
    |01 Jan 2001 09:00|

Scenario Outline: Reports for meeting
  Given a current published meeting exists of a committee to which I have a <relationship> relationship
  And the meeting has items on its agenda
  When I download the <type> report for the meeting
  Examples:
    |relationship |type      |
    |staff        |agenda pdf|

Scenario: Publish a meeting
  Given a current unpublished meeting exists of a committee to which I have a current chair relationship
  When I publish the meeting
  Then I should see the published meeting

