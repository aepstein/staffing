Feature: Manage memberships with interest
  In order to fill memberships based on interest
  As an authority
  I want to see information about interested users in membership side pane

  Background:
    Given a committee: "authority" exists
    And a position: "authority" exists
    And an enrollment exists with votes: 1, committee: committee "authority", position: position "authority"
    And a user: "authority" exists
    And a membership exists with user: user "authority", position: position "authority"
    And an authority: "focus" exists with committee: committee "authority"
    And a schedule exists
    And a period: "current" exists with schedule: the schedule
    And a period: "past" exists before period: "current" with schedule: the schedule
    And a position: "requestable_position" exists with requestable: true, authority: authority "focus", schedule: the schedule
    And a position: "requestable_committee" exists with requestable: false, requestable_by_committee: true, authority: authority "focus", schedule: the schedule
    And a committee: "requestable_committee" exists with requestable: true
    And an enrollment exists with committee: committee "requestable_committee", position: position "requestable_position"

  Scenario Outline: See memberships for which user is interested in renewal
    Given a user: "applicant" exists with first_name: "Very", last_name: "Interested"
    And a request exists with user: user "applicant", requestable: <what> "<requested>"
    And I log in as user: "authority"
    And a membership: "renewable" exists with position: position "requestable_position", user: user "applicant", period: period "past"
    And membership: "renewable" <renew> interested in renewal
    And the request has status: "<status>"
    And a membership: "current" exists with position: position "requestable_position", period: period "current"
    And I am on the edit page for membership: "current"
    Then I should <no_renewals> "No candidates" within "#hub-section-first"
    And I should <no_others> "No candidates" within "#hub-section-others"
    And I should <renewals> "Very Interested" within "#hub-section-first"
    And I should <others> "Very Interested" within "#hub-section-others"
    Examples:
      | what     | requested            | status | renew  | renewals | others  | no_renewals | no_others |
      | position | requestable_position | active | is     | see      | see     | not see     | not see   |
      | position | requestable_position | closed | is     | see      | not see | not see     | see       |
      | position | requestable_position | active | is not | not see  | see     | see         | not see   |
      | position | requestable_position | closed | is not | not see  | not see | see         | see       |

