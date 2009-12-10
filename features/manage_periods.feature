Feature: Manage periods
  In order to specify what terms may be served in a schedule
  As an administrator
  I want to create, edit, destroy, show or list periods

  Background:
    Given a schedule: "annual" exists with name: "Annual"

  Scenario: Register new period and edit
    Given I log in as the administrator
    And I am on the new period page for schedule: "annual"
    When I fill in "Starts at" with "2008-06-01"
    And I fill in "Ends at" with "2009-05-31"
    And I press "Create"
    Then I should see "Period was successfully created."
    And I should see "Schedule: Annual"
    And I should see "Starts at: June  1, 2008"
    And I should see "Ends at: May 31, 2009"
    When I follow "Edit"
    And I fill in "Starts at" with "2009-06-01"
    And I fill in "Ends at" with "2010-05-31"
    And I press "Update"
    Then I should see "Period was successfully updated."
    And I should see "Schedule: Annual"
    And I should see "Starts at: June  1, 2009"
    And I should see "Ends at: May 31, 2010"

  Scenario: Delete period
    Given a period exists with schedule: schedule "annual", starts_at: "2005-06-01", ends_at: "2006-05-31"
    And a period exists with schedule: schedule "annual", starts_at: "2006-06-01", ends_at: "2007-05-31"
    And a period exists with schedule: schedule "annual", starts_at: "2007-06-01", ends_at: "2008-05-31"
    And a period exists with schedule: schedule "annual", starts_at: "2008-06-01", ends_at: "2009-05-31"
    When I delete the 3rd period for schedule: "annual"
    Then I should see the following periods:
      |Starts at  |Ends at    |
      |1 Jun 2008|31 May 2009|
      |1 Jun 2007|31 May 2008|
      |1 Jun 2005|31 May 2006|

