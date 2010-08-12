Feature: Manage user_renewal_notices
  In order to schedule renewal notices to users
  As an administrator
  I want to create, modify, list, and delete user renewal notices

  Background:
    Given an authority: "sa" exists with name: "Student Assembly"
    And an authority: "ea" exists with name: "Employee Assembly"
    And a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for user_renewal_notices controller actions
    Given a user_renewal_notice exists
    And a user: "regular" exists
    And I log in as user: "<user>"
    And I am on the page for the user_renewal_notice
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the user_renewal_notices page
    Then I should <show> authorized
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New user renewal notice"
    Given I am on the new user_renewal_notice page
    Then I should <create> authorized
    Given I post on the user_renewal_notices page
    Then I should <create> authorized
    And I am on the edit page for the user_renewal_notice
    Then I should <update> authorized
    Given I put on the page for the user_renewal_notice
    Then I should <update> authorized
    Given I delete on the page for the user_renewal_notice
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | not see |

  Scenario: Register new user_renewal_notice and update
    Given I log in as user: "admin"
    And I am on the new user_renewal_notice page
    When I fill in "Starts at" with "2008-01-01"
    And I fill in "Ends at" with "2008-12-31"
    And I fill in "Deadline" with "2008-06-01"
    And I select "Student Assembly" from "Authority"
    And I fill in "Message" with "Time for *you* to renew."
    And I press "Create"
    Then I should see "Starts at: January 1st, 2008"
    And I should see "Ends at: December 31st, 2008"
    And I should see "Deadline: June 1st, 2008"
    And I should see "Authority: Student Assembly"
    And I should see "Time for you to renew."
    When I follow "Edit"
    And I fill in "Starts at" with "2009-01-01"
    And I fill in "Ends at" with "2009-12-31"
    And I fill in "Deadline" with "2009-06-01"
    And I select "Employee Assembly" from "Authority"
    And I fill in "Message" with "Now is the time for you to renew."
    And I press "Update"
    Then I should see "Starts at: January 1st, 2009"
    And I should see "Ends at: December 31st, 2009"
    And I should see "Deadline: June 1st, 2009"
    And I should see "Authority: Employee Assembly"
    And I should see "Now is the time for you to renew."

  Scenario: Delete user_renewal_notice
    Given a user_renewal_notice exists with starts_at: "2007-01-01", authority: authority "sa"
    And a user_renewal_notice exists with starts_at: "2008-01-01", authority: authority "sa"
    And a user_renewal_notice exists with starts_at: "2009-01-01", authority: authority "sa"
    And a user_renewal_notice exists with starts_at: "2010-01-01"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd user_renewal_notice
    Then I should see the following user_renewal_notices:
      |Starts at |Ends at   |Deadline  |Authority       |
      |1 Jan 2010|1 Jan 2011|8 Jan 2010|                |
      |1 Jan 2009|1 Jan 2010|8 Jan 2009|Student Assembly|
      |1 Jan 2007|1 Jan 2008|8 Jan 2007|Student Assembly|

