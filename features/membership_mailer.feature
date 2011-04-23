Feature: User mailer
  In order to send notices to the user
  As a reminder and notice driven organization
  I want to send email notices to users regarding their appointment to committees

  Background:
    Given a user: "focus" exists with first_name: "Johnny", last_name: "Applicant", email: "johnny.applicant@example.org"
    And an authority: "focus" exists with join_message: "We are very pleased to appoint you.", leave_message: "We are very sad to see you go."
    And an authority: "other" exists with contact_name: "Some Other Authority"
    And schedule: "focus" exists
    And a period: "focus" exists with schedule: the schedule, starts_at: "2008-06-01", ends_at: "2009-05-31"
    And a position: "requestable_committee" exists with name: "Lame position", join_message: "This position is lame.", leave_message: "This position was lame.", requestable: false, requestable_by_committee: true, authority: the authority, schedule: the schedule, authority: authority "focus"
    And a position: "requestable_position" exists with name: "Cool position", join_message: "This position is cool.", leave_message: "This position was cool.", requestable: true, requestable_by_committee: false, authority: the authority, schedule: the schedule, authority: authority "focus"
    And a position: "no_enrollment" exists with name: "Orphan position", requestable: false, requestable_by_committee: false, authority: authority "focus", schedule: the schedule, authority: authority "focus"
    And a position: "other_authority" exists with name: "Other authority", requestable: false, requestable_by_committee: false, schedule: the schedule, authority: authority "other"
    And a committee: "requestable_committee" exists with name: "Cool committee", join_message: "This committee is cool.", leave_message: "This committee was cool.", requestable: true
    And an enrollment exists with committee: the committee, position: position "requestable_committee"
    And an enrollment exists with committee: the committee, position: position "requestable_position"

  Scenario Outline: Send join notice to a user
    Given a membership exists with position: position "<position>", period: period "focus", user: user "focus"
    And a join notice email is sent for the membership
    And "johnny.applicant@example.org" opens the email
    Then I should see "Your appointment to <description>" in the email subject
    And I should see "Dear Johnny," in the email body
    And I should see "This notice is to inform you that you have been assigned a membership in <description>, for a term starting on June 1st, 2008 and ending on May 31st, 2009." in the email body
    And I should <authority> "We are very pleased to appoint you." in the email body
    And I should <committee> "This committee is cool." in the email body
    And I should <committee> "Concurrent with your appointment to this position, you hold the following committee enrollments:" in the email body
    And I should <cool> "This position is cool." in the email body
    And I should <lame> "This position is lame." in the email body
    And I should see "Best regards," in the email body
    And I should <authority> "The Authority" in the email body
    Examples:
      | position              | description     | authority | committee | cool    | lame     |
      | requestable_position  | Cool position   | see       | see       | see     | not see  |
      | requestable_committee | Cool committee  | see       | see       | not see | see      |
      | no_enrollment         | Orphan position | see       | not see   | not see | not see  |
      | other_authority       | Other authority | not see   | not see   | not see | not see  |

  Scenario Outline: Send leave notice to a user
    Given a membership exists with position: position "<position>", period: period "focus", user: user "focus"
    And a leave notice email is sent for the membership
    And "johnny.applicant@example.org" opens the email
    Then I should see "Expiration of your appointment to <description>" in the email subject
    And I should see "Dear Johnny," in the email body
    And I should see "This notice is to inform you that your membership in <description>, which began on June 1st, 2008, has expired as of May 31st, 2009." in the email body
    And I should <authority> "We are very sad to see you go." in the email body
    And I should <committee> "This committee was cool." in the email body
    And I should <committee> "Concurrent with your membership, your enrollment in the following committees has also expired:" in the email body
    And I should <cool> "This position was cool." in the email body
    And I should <lame> "This position was lame." in the email body
    And I should see "Best regards," in the email body
    And I should <authority> "The Authority" in the email body
    Examples:
      | position              | description     | authority | committee | cool    | lame     |
      | requestable_position  | Cool position   | see       | see       | see     | not see  |
      | requestable_committee | Cool committee  | see       | see       | not see | see      |
      | no_enrollment         | Orphan position | see       | not see   | not see | not see  |
      | other_authority       | Other authority | not see   | not see   | not see | not see  |

  Scenario Outline: Copy the watchers for a position
    Given a position: "watcher" exists with schedule: schedule "focus"
    And a committee: "other_committee" exists
    And an enrollment exists with committee: committee "<committee>_committee", position: position "watcher", membership_notices: true
    And a user: "watcher" exists with email: "watcher@example.com"
    And a membership: "watcher" exists with user: user "watcher", period: period "focus", position: position "watcher"
    And a membership: "focus" exists with user: user "focus", period: period "focus", position: position "requestable_position"
    And a <notice> notice email is sent for membership: "focus"
    And "johnny.applicant@example.org" opens the email
    Then I should <cc> "John Doe <watcher@example.com>" in the email "cc" header
    Examples:
      | committee   | notice | cc      |
      | requestable | join   | see     |
      | requestable | leave  | see     |
      | other       | join   | not see |
      | other       | leave  | not see |

