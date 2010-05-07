Feature: User mailer
  In order to send notices to the user
  As a reminder and notice driven organization
  I want to send email notices to users regarding their appointment to committees

  Scenario Outline: Send renewal notice to a user
    Given a user: "focus" exists with first_name: "David", last_name: "Skorton", email: "david.skorton@example.org"
    And a schedule exists
    And a period exists with schedule: the schedule, starts_at: "2008-06-01", ends_at: "2009-05-31"
    And an authority exists with name: "Board of Trustees", join_message: "Welcome on behalf of the Board."
    And a position: "focus" exists with name: "The Position", requestable: <p_req>, schedule: the schedule, authority: the authority, join_message: "Welcome to the position."
    And a committee: "First" exists with name: "The First Committee", requestable: <c_req>, join_message: "Welcome to First Committee."
    And a committee: "Second" exists with name: "The Second Committee", requestable: false, join_message: "Welcome to Second Committee."
    And a committee: "Third" exists with name: "The Third Committee", requestable: false, join_message: "Welcome to Third Committee."
    And an enrollment exists with position: position "focus", committee: committee "First", votes: 1, title: "Leader"
    And an enrollment exists with position: position "focus", committee: committee "<committee>", votes: 2, title: "Member"
    And a membership exists with user: user "focus", position: position "focus", period: the period
    And a join notice email is sent for the membership
    And "david.skorton@example.org" opens the email
    Then I should see "Your appointment to <description>" in the email subject
    And I should see the email delivered from "The Authority <info@example.org>"
    And I should see "Dear David," in the email body
    And I should see "This notice is to inform you that you have been assigned a membership in <description>, for a term starting on June 1st, 2008 and ending on May 31st, 2009." in the email body
    And I should see "Welcome on behalf of the Board." in the email body
    And I should see "Welcome to the position." in the email body
    And I should see "Welcome to First Committee." in the email body
    And I should see "Welcome to <committee> Committee." in the email body
    And I should not see "Welcome to <not_committee> Committee." in the email body
    And I should see "Leader of The First Committee with 1 vote" in the email body
    And I should see "Member of The <committee> Committee with 2 votes" in the email body
    And I should not see "Member of The <not_committee> Committee with 2 votes" in the email body
    Examples:
      | p_req | c_req | description         | committee | not_committee |
      | true  | true  | The Position        | Second    | Third         |
      | true  | false | The Position        | Second    | Third         |
      | true  | true  | The Position        | Third     | Second        |
      | false | true  | The First Committee | Second    | Third         |
      | false | false | The Position        | Second    | Third         |

