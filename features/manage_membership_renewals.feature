Feature: Manage membership renewals
  In order to record membership renewal interest
  As a member of committees
  I want to register my renewal preferences

  Background:
    Given a schedule exists
    And a period: "current" exists with schedule: the schedule
    And a period: "future" exists after period: "current" with schedule: the schedule
    And a position: "renewable" exists with name: "Renewable", schedule: the schedule, renewable: true
    And a position: "nonrenewable" exists with name: "Nonrenewable", schedule: the schedule
    And a user: "popular" exists with first_name: "Mister", last_name: "Popularity"
    And a membership: "nonrenewable" exists with position: position "nonrenewable", user: user "popular", period: period "current"
    And a membership: "renewable" exists with position: position "renewable", user: user "popular", period: period "current"
    And I log in as user: "popular"
    And I am on the renew memberships page for user: "popular"

  Scenario: Invalid entries
    When I fill in "Renewable" with 1 week after today
    And I press "Update renewals"
    Then show me the page
    Then I should not see "Renewal preferences successfully updated."
    And I should see "Renew until must be after" within "table"

  Scenario: Register renewals of memberships with valid entries
    Then I should not see "Officer"
    When I fill in "Renewable" with 13 months after today
    And I select "Yes" from "Notify again?"
    And I press "Update renewals"
    Then I should see "Renewal preferences successfully updated."
    And the "Renewable" field should contain 13 months after today
#    And the "Notify again?" field should contain "Yes"
    And membership: "renewable"'s renew_until should not be nil
    And membership: "renewable"'s renewal_confirmed_at should not be nil
    When I select "No" from "Notify again?"
    And I press "Update renewals"
    Then I should see "Renewal preferences successfully updated."
    And user: "popular"'s renewal_checkpoint should not be nil

