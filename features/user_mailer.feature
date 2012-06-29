Feature: User mailer
  In order to send notices regarding recently expired or about to expire renewable memberships
  As a person potentially interested in renewing membership
  I want to send email notices to users

  Background:
    Given a user exists with first_name: "John", last_name: "Doe"
    And a schedule exists
    And a period: "current" exists with schedule: the schedule
    And a period: "past" exists before period: "current" with schedule: the schedule
    And a period: "long_ago" exists before period: "past" with schedule: the schedule
    And a period: "future" exists after period: "current" with schedule: the schedule

  Scenario Outline: Send renewal notice to a user
    Given a position exists with name: "Focus Position", renewable: <renewable>
    And a committee exists with name: "Focus Committee"
    And an enrollment exists with position: the position, committee: the committee, requestable: <req>
    And a membership exists with period: period "<period>", position: the position, user: the user
    And the membership <renew> interested in renewal
    And the membership <confirm> confirmed renewal preference
    And a renew_notice email is sent for the user
    Then 1 email should be delivered to the user
    And the email should have subject: "Your Action is Required to Renew Committee Memberships"
    And the email should have from: "info@example.org"
    And the email should contain "You are receiving this notice because you have memberships either ending soon or recently ended and your action is required to renew your membership." in the text part body
    And the email should contain "You are receiving this notice because you have memberships either ending soon or recently ended and your action is required to renew your membership." in the html part body
    And the email should <interest> contain " * interested in renewing your membership in Focus <description>" in the text part body
    And the email should <interest> contain "<li>interested in renewing your membership in Focus <description>" in the html part body
    And the email should <disinterest> contain "*not* interested in renewing your membership in Focus <description>" in the text part body
    And the email should <disinterest> contain "<em>not</em> interested in renewing your membership in Focus <description>" in the html part body
    And the email should <past> contain "that ended on" in the text part body
    And the email should <past> contain "that ended on" in the html part body
    And the email should <present> contain "that ends on" in the text part body
    And the email should <present> contain "that ends on" in the html part body
    And the email should <confirmed> contain "Our records also indicate you have confirmed you are:" in the text part body
    And the email should <confirmed> contain "Our records also indicate you have confirmed you are:" in the html part body
    And the email should <unconfirmed> contain "According to our records you have the following unconfirmed renewal preferences.  You are:" in the text part body
    And the email should <unconfirmed> contain "According to our records you have the following unconfirmed renewal preferences.  You are:" in the html part body
    And the email should contain "Please contact The Authority <info@example.org> if you have any questions or concerns.  Thank you for your time and your consideration." in the text part body
    And the email should contain "Please contact The Authority <info@example.org> if you have any questions or concerns.  Thank you for your time and your consideration." in the html part body
    Examples:
|renewable|req  |period  |renew |confirm|description|interest|disinterest|past|present|confirmed|unconfirmed|
|true     |false|current |is not|has not|Position   |not     |           |not |       |not      |           |
|true     |true |current |is not|has not|Committee  |not     |           |not |       |not      |           |
|true     |false|current |is    |has not|Position   |        |not        |not |       |not      |           |
|true     |false|current |is    |has    |Position   |        |not        |not |       |         |not        |
|true     |false|past    |is not|has not|Position   |not     |           |    |not    |not      |           |
|true     |false|long_ago|is not|has not|Position   |not     |not        |not |not    |not      |not        |
|true     |false|future  |is not|has not|Position   |not     |not        |not |not    |not      |not        |
|false    |false|current |is not|has not|Position   |not     |not        |not |not    |not      |not        |

