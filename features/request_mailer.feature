Feature: Request mailer
  In order to send notices to the user about membership requests
  As a reminder and notice driven organization
  I want to send email notices to users regarding their requests for memberships

  Scenario Outline: Send reject notice to a user
    Given a user: "focus" exists with first_name: "Johnny", last_name: "Applicant", email: "johnny.applicant@example.org"
    And an authority exists with reject_message: "Authority is *very* selective."
    And a position exists with name: "Cool position", reject_message: "position is not for *everyone*.", requestable: true, requestable_by_committee: true
    And a committee exists with name: "Cool committee", reject_message: "committee is not for *everyone*.", requestable: true
    And an enrollment exists with committee: the committee, position: the position
    And a request exists with requestable: the <what>, user: user "focus"
    And a user: "admin" exists with admin: true
    And user: "admin" rejects the request with authority: the authority, message: "Committee is *full*."
    And a reject notice email is sent for the request
    And "johnny.applicant@example.org" opens the email
    Then I should see "Your request for appointment to Cool <what> was declined" in the email subject
    And I should see the email delivered from "The Authority <info@example.org>"
    And I should see "Dear Johnny," in the email body
    And I should see "This notice is to inform you that your request for appointment to Cool <what> has been declined for the following reason(s):" in the email body
    And I should see "Committee is <em>full</em>." in the email body
    And I should see "<what> is not for <em>everyone</em>." in the email body
    And I should see "Authority is <em>very</em> selective." in the email body
    And I should see "The Authority" in the email body
    Examples:
      | what      |
      | position  |
      | committee |

