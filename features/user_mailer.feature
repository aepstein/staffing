Feature: User mailer
  In order to send notices regarding recently expired or about to expire renewable memberships
  As a person potentially interested in renewing membership
  I want to send email notices to users

  Scenario Outline: Send renewal notice to a user
    Given a user exists with first_name: "John", last_name: "Doe", email: "john.doe@example.org"
    And a schedule exists
    And a period: "current" exists with schedule: the schedule
    And a period: "past" exists before period: "current" with schedule: the schedule
    And a period: "long_ago" exists before period: "past" with schedule: the schedule
    And a period: "future" exists after period: "current" with schedule: the schedule
    And a position exists with name: "Focus Position", renewable: <renewable>, requestable: <p_req>, requestable_by_committee: <c_req>
    And a committee exists with name: "Focus Committee", requestable: <c_req>
    And an enrollment exists with position: the position, committee: the committee
    And a membership exists with period: period "<period>", position: the position, user: the user
    And the membership <renew> interested in renewal
    And the membership <confirm> confirmed renewal preference
    And a renew_notice email is sent for the user
    And "john.doe@example.org" opens the email
    Then I should see "Your Action is Required to Renew Committee Memberships" in the email subject
    And I should see the email delivered from "info@example.org"
    And I should see "You are receiving this notice because you have memberships either ending soon or recently ended and your action is required to renew your membership." in the email text part body
    And I should <interest> " * interested in renewing your membership in <description>" in the email text part body
    And I should <disinterest> "*not* interested in renewing your membership in <description>" in the email text part body
    And I should <confirmed> "Our records also indicate you have confirmed you are:" in the email text part body
    And I should <unconfirmed> "According to our records you have the following unconfirmed renewal preferences.  You are:" in the email text part body
    And I should see "Please contact The Authority <info@example.org> if you have any questions or concerns.  Thank you for your time and your consideration." in the email text part body
    Examples:
      | renewable | p_req | c_req | period   | renew  | confirm | description     | interest | disinterest | confirmed | unconfirmed |
      | true      | false | false | current  | is not | has not | Focus Position  | not see  | see         | not see   | see         |
      | true      | false | true  | current  | is not | has not | Focus Committee | not see  | see         | not see   | see         |
      | true      | false | false | current  | is     | has not | Focus Position  | see      | not see     | not see   | see         |
      | true      | false | false | current  | is     | has     | Focus Position  | see      | not see     | see       | not see     |
      | true      | false | false | past     | is not | has not | Focus Position  | not see  | see         | not see   | see         |
      | true      | false | false | long_ago | is not | has not | Focus Position  | not see  | not see     | not see   | not see     |
      | true      | false | false | future   | is not | has not | Focus Position  | not see  | not see     | not see   | not see     |
      | false     | false | false | current  | is not | has not | Focus Position  | not see  | not see     | not see   | not see     |

