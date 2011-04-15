Feature: Request mailer
  In order to send notices to the user about membership requests
  As a reminder and notice driven organization
  I want to send email notices to users regarding their requests for memberships

  Background:
    Given a user: "focus" exists with first_name: "Johnny", last_name: "Applicant", email: "johnny.applicant@example.org"
    And an authority exists with reject_message: "Authority is *very* selective."
    And a position: "requestable_committee" exists with name: "Lame position", reject_message: "position is not for *everyone*.", requestable: false, requestable_by_committee: true, authority: the authority
    And a position: "requestable_position" exists with name: "Cool position", reject_message: "position is not for *everyone*.", requestable: true, requestable_by_committee: false, authority: the authority
    And a committee: "requestable_committee" exists with name: "Cool committee", reject_message: "committee is not for *everyone*.", requestable: true
    And an enrollment exists with committee: the committee, position: position "requestable_committee"

  Scenario Outline: Send reject notice to a user
    Given a request exists with requestable: <what> "requestable_<what>", user: user "focus"
    And a user: "admin" exists with admin: true
    And user: "admin" rejects the request with authority: the authority, message: "Committee is *full*."
    And a reject notice email is sent for the request
    And "johnny.applicant@example.org" opens the email
    Then I should see "Your request for appointment to Cool <what> was declined" in the email subject
    And I should see the email delivered from "The Authority <info@example.org>"
    And I should see "Dear Johnny," in the email text part body
    And I should see "This notice is to inform you that your request for appointment to Cool <what> has been declined for the following reason(s):" in the email text part body
    And I should see "Committee is <em>full</em>." in the email html part body
    And I should see "<what> is not for <em>everyone</em>." in the email html part body
    And I should see "Authority is <em>very</em> selective." in the email html part body
    And I should see "The Authority" in the email text part body
    Examples:
      | what      |
      | position  |
      | committee |

  Scenario Outline: Send close notice to a user
    Given a request exists with requestable: <request> "requestable_<request>", user: user "focus"
    And an enrollment exists with committee: committee "requestable_committee", position: position "requestable_committee"
    And a user: "other" exists
    And a position: "nonrequestable" exists with requestable_by_committee: false
    And an enrollment exists with position: position "nonrequestable", committee: committee "requestable_committee"
    And a position: "other_committee" exists with requestable_by_committee: true
    And an enrollment exists with position: position "other_committee"
    And a membership exists with position: position "<position>", user: user "<user>"
    And a close notice email is sent for the request
    And "johnny.applicant@example.org" opens the email
    Then I should see "Your request for appointment to Cool <request> was approved" in the email subject
    And I should see the email delivered from "The Authority <info@example.org>"
    And I should see "Dear Johnny," in the email text part body
    And I should see "This notice is to inform you that your request for appointment to Cool <request> has been approved." in the email text part body
    And I should see "Your request is now considered closed.  No further appointments will be made in response to your request unless you explicitly reopen it by updating it online.  If you have additional questions or concerns regarding this notice or your appointment, please contact The Authority <info@example.org>." in the email text part body
    And I should <membership> "You have been appointed to the following position:" in the email text part body
    And I should <enrollment> "You have been appointed to the following positions:" in the email text part body
    And I should <membership> "* Cool position for a term beginning" in the email text part body
    And I should <enrollment> "* member in Cool committee for a term beginning" in the email text part body
    And I should <empty> "You have not been appointed to any positions as a result of this request.  This is most likely for reasons communicated to you or by you separately from this notice." in the email text part body
    Examples:
      | request   | position              | user  | membership | enrollment | empty   |
      | position  | requestable_position  | focus | see        | not see    | not see |
      | committee | requestable_committee | focus | not see    | see        | not see |
      | committee | other_committee       | focus | not see    | not see    | see     |
      | committee | nonrequestable        | focus | not see    | not see    | see     |
      | position  | requestable_position  | other | not see    | not see    | see     |

