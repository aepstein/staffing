Feature: Manage meetings
  In order to specify what rolls a position confers
  As an administrator
  I want to create, modify, list, show, and destroy meetings

  Background:
    Given a position: "member" exists with name: "Member of Committee"
    And a position: "ex-officio" exists with name: "Ex-Officio Member of Committee"
    And a schedule exists
    And a period: "past" exists with schedule: the schedule, starts_at: "2010-01-01", ends_at: "2010-12-31"
    And a period: "distant_past" exists with schedule: the schedule, starts_at: "2009-01-01", ends_at: "2009-12-31"
    And a committee: "committee" exists with name: "Favorite Committee", schedule: the schedule
    And a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for meetings controller actions
    Given a meeting exists with committee: committee "committee", period: period "past", location: "Focus"
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the meeting
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the meetings page
    And I am on the meetings page for committee: "committee"
    Then I should <show> "Focus"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New meeting"
    Given I am on the new meeting page for committee: "committee"
    Then I should <create> authorized
    Given I post on the meetings page for committee: "committee"
    Then I should <create> authorized
    And I am on the edit page for the meeting
    Then I should <update> authorized
    Given I put on the page for the meeting
    Then I should <update> authorized
    Given I delete on the page for the meeting
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new meeting and edit
    Given a motion exists with name: "Easy Motion", committee: committee "committee", period: period "past"
    And a motion exists with name: "Difficult Motion", committee: committee "committee", period: period "past"
    And I log in as user: "admin"
    And I am on the new meeting page for committee: "committee"
    When I select "1 Jan 2010 - 31 Dec 2010" from "Period"
    And I fill in "Starts at" with "15 Jan 2010 16:00:00"
    And I fill in "Ends at" with "15 Jan 2010 18:00:00"
    And I fill in "Location" with "Green Room"
    And I press "Create"
    Then I should see "Meeting was successfully created."
    And I should see "Committee: Favorite Committee"
    And I should see "Period: 1 Jan 2010 - 31 Dec 2010"
    And I should see "Starts at: January 15th, 2010 16:00"
    And I should see "Ends at: January 15th, 2010 18:00"
    And I should see "Location: Green Room"
    And I should see "Audio? No"
    When I follow "Edit"
    And I fill in "Starts at" with "16 Jan 2010 16:00:00"
    And I fill in "Ends at" with "16 Jan 2010 18:00:00"
    And I fill in "Location" with "Red Room"
    And I fill in "Motion" with "Difficult Motion"
    And I attach the file "spec/assets/audio.mp3" to "Audio"
    And I press "Update"
    Then I should see "Meeting was successfully updated."
    And I should see "Committee: Favorite Committee"
    And I should see "Starts at: January 16th, 2010 16:00"
    And I should see "Ends at: January 16th, 2010 18:00"
    And I should see "Location: Red Room"
    And I should see "Motions: Difficult Motion"
    And I should see "Audio? Yes"
    When I follow "Edit"
    And I check "Remove motion"
    And I fill in "Motion" with "Easy Motion"
    And I press "Update"
    Then I should see "Motions: Easy Motion"
    And I should not see "Difficult Motion"

  Scenario: Delete meeting
    Given an meeting: "meeting4" exists with committee: committee "committee", period: period "past", starts_at: "2010-01-01 16:00:00"
    And an meeting: "meeting3" exists with committee: committee "committee", period: period "past", starts_at: "2010-01-02 16:00:00"
    And an meeting: "meeting2" exists with committee: committee "committee", period: period "past", starts_at: "2010-01-03 16:00:00"
    And an meeting: "meeting1" exists with committee: committee "committee", period: period "past", starts_at: "2010-01-04 16:00:00"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd meeting for committee: "committee"
    Then I should see the following meetings:
      | Starts at        |
      |04 Jan 2010 16:00 |
      |03 Jan 2010 16:00 |
      |01 Jan 2010 16:00 |

