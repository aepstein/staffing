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
    And a position: "requestable_position" exists with renewable: true, requestable: true, authority: authority "focus", schedule: the schedule
    And a position: "requestable_committee" exists with renewable: true, requestable: false, requestable_by_committee: true, authority: authority "focus", schedule: the schedule
    And a committee: "requestable_committee" exists with requestable: true
    And an enrollment exists with committee: committee "requestable_committee", position: position "requestable_committee"

  Scenario Outline: See memberships for which user is interested in renewal
    Given a user: "applicant" exists with first_name: "Very", last_name: "Interested"
    And a user: "other" exists
    And a request exists with user: user "applicant", requestable: <what> "requestable_<what>"
    And a membership: "renewable" exists with position: position "requestable_<what>", user: user "<incumbent>", period: period "past"
    And membership: "renewable" <renew> interested in renewal
    And a membership: "current" exists with position: position "requestable_<what>", period: period "current"
    And membership: "current" has no renewed_memberships
    And the request has status: "<status>"
    And I log in as user: "authority"
    And I am on the edit page for membership: "current"
    Then I should <renewals> "Very Interested" within "#renewal_candidates"
    And I should <new> "Very Interested" within "#new_candidates"
    And I should <no_renewals> "No candidates" within "#renewal_candidates"
    And I should <no_new> "No candidates" within "#new_candidates"
    Examples:
      |what     |status|incumbent|renew |renewals|new    |no_renewals|no_new |
      |position |active|other    |is    |not see |see    |not see    |not see|
      |position |closed|other    |is    |not see |not see|not see    |see    |
      |position |active|other    |is not|not see |see    |see        |not see|
      |position |closed|other    |is not|not see |not see|see        |see    |
      |position |active|applicant|is    |see     |see    |not see    |not see|
      |position |closed|applicant|is    |see     |not see|not see    |see    |
      |position |active|applicant|is not|not see |see    |see        |not see|
      |position |closed|applicant|is not|not see |not see|see        |see    |
      |committee|active|other    |is    |not see |see    |not see    |not see|
      |committee|closed|other    |is    |not see |not see|not see    |see    |
      |committee|active|other    |is not|not see |see    |see        |not see|
      |committee|closed|other    |is not|not see |not see|see        |see    |
      |committee|active|applicant|is    |see     |see    |not see    |not see|
      |committee|closed|applicant|is    |see     |not see|not see    |see    |
      |committee|active|applicant|is not|not see |see    |see        |not see|
      |committee|closed|applicant|is not|not see |not see|see        |see    |

