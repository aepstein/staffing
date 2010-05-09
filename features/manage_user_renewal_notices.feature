Feature: Manage user_renewal_notices
  In order to schedule renewal notices to users
  As an administrator
  I want to create, modify, list, and delete user renewal notices

  Background:
    Given an authority: "sa" exists with name: "Student Assembly"
    And an authority: "ea" exists with name: "Employee Assembly"

  Scenario Outline: Test permissions for user_renewal_notices controller actions
    Given a user_renewal_notice exists
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And I log in as "<user>" with password "secret"
    And I am on the new user_renewal_notice page
    Then I should <create>
    Given I post on the user_renewal_notices page
    Then I should <create>
    And I am on the edit page for the user_renewal_notice
    Then I should <update>
    Given I put on the page for the user_renewal_notice
    Then I should <update>
    Given I am on the page for the user_renewal_notice
    Then I should <show>
    Given I am on the user_renewal_notices page
    Then I should <show>
    Given I delete on the page for the user_renewal_notice
    Then I should <destroy>
    Examples:
      | user    | create                   | update                   | destroy                  | show                     |
      | admin   | not see "not authorized" | not see "not authorized" | not see "not authorized" | not see "not authorized" |
      | regular | see "not authorized"     | see "not authorized"     | see "not authorized"     | see "not authorized"     |

  Scenario: Register new user_renewal_notice and update
    Given I log in as the administrator
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
    And I log in as the administrator
    When I delete the 3rd user_renewal_notice
    Then I should see the following user_renewal_notices:
      |Starts at |Ends at   |Deadline  |Authority       |
      |1 Jan 2010|1 Jan 2011|8 Jan 2010|                |
      |1 Jan 2009|1 Jan 2010|8 Jan 2009|Student Assembly|
      |1 Jan 2007|1 Jan 2008|8 Jan 2007|Student Assembly|

