Feature: User mailer
  In order to send notices regarding recently expired or about to expire renewable memberships
  As a person potentially interested in renewing membership
  I want to send email notices to users
  @wip
  Scenario Outline: Send renewal notice to a user
    Given a user: "focus" exists with first_name: "John", last_name: "Doe", email: "john.doe@example.org", password: "secret"
    And a user: "other" exists
    And a schedule exists
    And a period exists with schedule: the schedule, starts_at: "2008-01-01", ends_at: "2008-12-31"
    And a position: "focus" exists with name: "Focus Position", requestable: <p_req>, renewable: <renewable>, schedule: the schedule
    And a position: "other" exists with name: "Other Position", requestable: true, renewable: <renewable>, schedule: the schedule
    And a committee: "focus" exists with name: "Focus Committee", requestable: <c_req>
    And a committee: "other" exists with name: "Other Committee", requestable: true
    And an enrollment exists with position: position "<position>", committee: committee "focus"
    And a request: "focus" exists with requestable: <requestable>, user: user "<requestor>"
    And a membership: "focus" exists with user: user "focus", position: position "focus", period: the period, request: <request>
    And a user_renewal_notice exists with starts_at: "<starts>", ends_at: "<ends>", message: "Please *renew*."
    And a sending exists with message: the user_renewal_notice, user: user "focus"
    And a sending email is sent for the sending
    And "john.doe@example.org" opens the email
    Then I should see "Your Action is Required to Renew Your Committee Memberships" in the email subject
    And I should see the email delivered from "info@example.org"
    And I should <s_int> "You are interested in reappointment" in the email text part body
    And I should <s_nint> "You are *not* interested in reappointment" in the email text part body
    And I should <s_pos> "Focus Position" in the email text part body
    And I should <s_com> "Focus Committee" in the email text part body
    And I should see "Please contact The Authority <info@example.org> if you have any questions or concerns.  Thank you for your time and your consideration." in the email text part body
    And I should see "Please *renew*." in the email text part body
    Examples:
      |starts    |ends      |p_req|c_req|renewable|requestable      |requestor|request    |position|s_int  |s_nint |s_pos  |s_com  |
      |2008-01-01|2008-12-31|true |true |true     |position "focus" |focus    |the request|focus   |not see|see    |see    |not see|
      |2008-01-01|2008-12-31|false|true |true     |committee "focus"|focus    |the request|focus   |not see|see    |not see|see    |
      |2008-01-01|2008-12-31|false|true |true     |committee "focus"|other    |nil        |focus   |not see|see    |not see|see    |
      |2008-01-01|2008-12-31|false|false|true     |committee "other"|other    |nil        |focus   |not see|not see|not see|not see|
      |2008-01-01|2008-12-31|false|true |false    |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|
      |2008-01-02|2008-12-31|false|true |true     |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|
      |2008-01-01|2008-12-30|false|true |true     |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|

