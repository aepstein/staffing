Feature: User mailer
  In order to send notices to the user
  As a reminder and notice driven organization
  I want to send email notices to users regarding their appointment to committees

  Background:
    Given a user: "focus" exists with first_name: "Johnny", last_name: "Applicant"
    And an authority: "focus" exists with join_message: "We are *very* pleased to appoint you.", leave_message: "We are *very* sad to see you go."
    And an authority: "other" exists with contact_name: "Some Other Authority"
    And schedule: "focus" exists
    And a period: "focus" exists with schedule: the schedule, starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "requestable_committee" exists with name: "Lame position", join_message: "This position is *lame*.", leave_message: "This position was *lame*.", authority: the authority, schedule: the schedule, authority: authority "focus"
    And a position: "no_enrollment" exists with name: "Orphan position", authority: authority "focus", schedule: the schedule, authority: authority "focus"
    And a position: "other_authority" exists with name: "Other authority", schedule: the schedule, authority: authority "other"
    And a committee: "requestable_committee" exists with name: "Cool committee", join_message: "This committee is *cool*.", leave_message: "This committee was *cool*."
    And an enrollment exists with committee: the committee, position: position "requestable_committee", requestable: true

  Scenario Outline: Send leave notice to a user
    Given a membership exists with position: position "<position>", period: period "focus", user: user "focus"
    And a leave notice email is sent for the membership
    Then 1 email should be delivered to user: "focus"
    And the email should have subject: "Expiration of your appointment to <description>", from: "info@example.org"
    And the email should contain "Dear Johnny," in the both parts body
    And the email should contain "This notice is to inform you that your membership in <description>, which began on June 1st, 2008, has expired as of May 31st, 2009." in the both parts body
    And the email should <authority> contain "We are *very* sad to see you go." in the text part body
    And the email should <authority> contain "We are <em>very</em> sad to see you go." in the html part body
    And the email should <committee> contain "This committee was *cool*." in the text part body
    And the email should <committee> contain "This committee was <em>cool</em>." in the html part body
    And the email should <committee> contain "Concurrent with your membership, your enrollment in the following committees has also expired:" in the text part body
    And the email should <committee> contain "Concurrent with your membership, your enrollment in the following committees has also expired:" in the html part body
    And the email should <cool> contain "This position was *cool*." in the text part body
    And the email should <cool> contain "This position was <em>cool</em>." in the html part body
    And the email should <lame> contain "This position was *lame*." in the text part body
    And the email should <lame> contain "This position was <em>lame</em>." in the html part body
    And the email should contain "Best regards," in the both parts body
    And the email should <authority> contain "The Authority" in the both parts body
    Examples:
      | position              | description     | authority | committee | cool    | lame     |
      | requestable_committee | Cool committee  |           |           | not     |          |
      | no_enrollment         | Orphan position |           | not       | not     | not      |
      | other_authority       | Other authority | not       | not       | not     | not      |

  Scenario Outline: Send decline notice to a user
    Given a membership exists with position: position "<position>", period: period "focus", user: user "focus", decline_comment: "No *membership* for you!"
    And the membership is declined renewal
    And a decline notice email is sent for the membership
    Then 1 email should be delivered to user: "focus"
    And the email should have subject: "Renewal of your appointment to <description> was declined", from: "info@example.org"
    And the email should contain "Dear Johnny" in the both parts body
    And the email should contain "This notice is to inform you that your membership in <description>, which began on June 1st, 2008, will not be renewed beyond the originally scheduled end date of May 31st, 2009." in the both parts body
    And the email should contain "No *membership* for you!" in the text part body
    And the email should contain "No <em>membership</em> for you!" in the html part body
    And the email should contain "Best regards," in the both parts body
    And the email should <authority> contain "The Authority" in the both parts body
    Examples:
      | position              | description     | authority |
      | requestable_committee | Cool committee  |           |
      | no_enrollment         | Orphan position |           |
      | other_authority       | Other authority | not       |

  Scenario Outline: Copy the watchers for a position
    Given a position: "watcher" exists with schedule: schedule "focus"
    And a committee: "other_committee" exists
    And an enrollment exists with committee: committee "<committee>_committee", position: position "watcher", membership_notices: true
    And a user: "watcher" exists with email: "watcher@example.com"
    And a membership: "watcher" exists with user: user "watcher", period: period "focus", position: position "watcher"
    And a membership: "focus" exists with user: user "focus", period: period "focus", position: position "requestable_committee"
    And a <notice> notice email is sent for membership: "focus"
    Then 1 email should be delivered to user: "focus"
    And the email <cc> be copied to user: "watcher"
    Examples:
      | committee   | notice | cc         |
      | requestable | join   | should     |
      | requestable | leave  | should     |
      | other       | join   | should not |
      | other       | leave  | should not |

