Feature: Request mailer
  In order to send notices to the user about membership requests
  As a reminder and notice driven organization
  I want to send email notices to users regarding their requests for memberships

  Background:
    Given a user: "focus" exists with first_name: "Johnny", last_name: "Applicant"
    And an authority exists with reject_message: "Authority is *very* selective."
    And a position: "committee" exists with name: "Lame position", reject_message: "position is not for *everyone*.", authority: the authority
    And a position: "position" exists with name: "Cool position", reject_message: "position is not for *everyone*.", authority: the authority
    And a committee: "requestable" exists with name: "Cool committee", reject_message: "committee is not for *everyone*."
    And an enrollment exists with committee: the committee, position: position "committee", requestable: true

  Scenario Outline: Send close notice to a user
    Given a request exists with committee: committee "requestable", user: user "focus"
    And a user: "other" exists
    And a position: "nonrequestable" exists
    And an enrollment exists with position: position "nonrequestable", committee: committee "requestable", requestable: false
    And a membership exists with position: position "<position>", user: user "<user>"
    And a close notice email is sent for the request
    Then 1 email should be delivered to user: "focus"
    And the email should have subject: "Your request for appointment to Cool committee was approved", from: "info@example.org"
    And the email should contain "Dear Johnny," in the both parts body
    And the email should contain "This notice is to inform you that your request for appointment to Cool committee has been approved." in the both parts body
    And the email should contain "Your request is now considered closed.  No further appointments will be made in response to your request unless you explicitly reopen it by updating it online.  If you have additional questions or concerns regarding this notice or your appointment, please contact The Authority <info@example.org>." in the text part body
    And the email should contain "Your request is now considered closed.  No further appointments will be made in response to your request unless you explicitly reopen it by updating it online.  If you have additional questions or concerns regarding this notice or your appointment, please contact The Authority &lt;info@example.org&gt;." in the html part body
    And the email should <enroll> contain "You have been appointed to the following position:" in the both parts body
    And the email should <enroll> contain "* member in Cool committee for a term beginning" in the text part body
    And the email should <enroll> contain "<li>member in Cool committee for a term beginning" in the html part body
    And the email should <empty> contain "You have not been appointed to any positions as a result of this request.  This is most likely for reasons communicated to you or by you separately from this notice." in the both parts body
    Examples:
      | position       | user  | enroll | empty |
      | committee      | focus |        | not   |
      | nonrequestable | focus | not    |       |

