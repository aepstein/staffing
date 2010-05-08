Feature: User mailer
  In order to send notices to the user
  As a reminder and notice driven organization
  I want to send email notices to users

  Scenario Outline: Send renewal notice to a user
    Given a user: "focus" exists with net_id: "focus", first_name: "John", last_name: "Doe", email: "john.doe@example.org", password: "secret"
    And a user: "other" exists
    And a schedule exists
    And a <period>period exists with schedule: the schedule
    And a position: "focus" exists with name: "Focus Position", requestable: <p_req>, renewable: <renewable>, schedule: the schedule
    And a position: "other" exists with name: "Other Position", requestable: true, renewable: <renewable>, schedule: the schedule
    And a committee: "focus" exists with name: "Focus Committee", requestable: <c_req>
    And a committee: "other" exists with name: "Other Committee", requestable: true
    And an enrollment exists with position: position "<position>", committee: committee "focus"
    And a request: "focus" exists with requestable: <requestable>, user: user "<requestor>"
    And a membership: "focus" exists with user: user "focus", position: position "focus", period: the period, request: <request>
    And a renewal reminder email is sent for user: "focus"
    And "john.doe@example.org" opens the email
    Then I should see "Your Committee Memberships Are Expiring" in the email subject
    And I should <s_int> "You are interested in reappointment" in the email body
    And I should <s_nint> "You are *not* interested in reappointment" in the email body
    And I should <s_pos> "Focus Position" in the email body
    And I should <s_com> "Focus Committee" in the email body
    And I should see "Please contact The Authority <info@example.org> if you have any questions or concerns.  Thank you for your time and your consideration."
    Examples:
      |period |p_req|c_req|renewable|requestable      |requestor|request    |position|s_int  |s_nint |s_pos  |s_com  |
      |       |true |true |true     |position "focus" |focus    |the request|focus   |not see|see    |see    |not see|
      |       |false|true |true     |committee "focus"|focus    |the request|focus   |not see|see    |not see|see    |
      |       |false|true |true     |committee "focus"|other    |nil        |focus   |not see|see    |not see|see    |
      |       |false|false|true     |committee "other"|other    |nil        |focus   |not see|not see|not see|not see|
      |       |false|true |false    |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|
      |future_|false|true |true     |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|
      |past_  |false|true |true     |committee "focus"|focus    |the request|focus   |not see|not see|not see|not see|

