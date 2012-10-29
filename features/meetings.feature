Feature: Manage meetings
  In order to record meetings to associate with committees and motions
  As a staff member or committee member
  I want to create, modify, list, show, and destroy meetings

Scenario Outline: Access control
  Given an authorization scenario of a <meeting_tense> <pub>published meeting of a committee to which I have a <member_tense> <role> relationship
  Then I <show> see the meeting
  And I <create> create meetings
  And I <update> update the meeting
  And I <destroy> destroy the meeting
  Examples:
    |role    |pub|meeting_tense|member_tense|show   |create |update |destroy|
    |admin   |un |current      |current     |may    |may    |may    |may    |
    |admin   |un |past         |current     |may    |may    |may    |may    |
    |admin   |un |future       |current     |may    |may    |may    |may    |
    |staff   |un |current      |current     |may    |may    |may    |may    |
    |staff   |un |past         |current     |may    |may    |may    |may not|
    |staff   |un |future       |current     |may    |may    |may    |may not|
    |chair   |un |current      |current     |may    |may    |may    |may    |
    |chair   |un |recent       |current     |may    |may    |may    |may    |
    |chair   |un |pending      |current     |may    |may    |may    |may    |
    |chair   |un |current      |recent      |may not|may not|may not|may not|
    |chair   |un |current      |recent      |may not|may not|may not|may not|
    |chair   |un |current      |pending     |may    |may not|may not|may not|
    |voter   |un |current      |current     |may    |may not|may not|may not|
    |voter   |un |pending      |current     |may    |may not|may not|may not|
    |voter   |un |pending      |pending     |may    |may not|may not|may not|
    |nonvoter|un |current      |current     |may    |may not|may not|may not|
    |nonvoter|un |pending      |current     |may    |may not|may not|may not|
    |nonvoter|un |pending      |pending     |may    |may not|may not|may not|
    |plain   |un |current      |current     |may not|may not|may not|may not|
    |plain   |un |recent       |current     |may    |may not|may not|may not|
    |plain   |   |current      |current     |may    |may not|may not|may not|
    |plain   |   |pending      |current     |may    |may not|may not|may not|

Scenario Outline: Create/edit a meeting
  Given I log in as the staff user
  When I create a meeting as <role>
  Then I should see the new meeting
  When I update the meeting
  Then I should see the edited meeting
  Examples:
    |role |
    |staff|
    |chair|

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

