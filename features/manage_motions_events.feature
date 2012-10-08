Feature: Manage motions
  In order to record motions of committees
  As a committee member or administrator
  I want to trigger events on motion

  Background:
    Given a schedule exists
    And a period exists with schedule: the schedule
    And a committee exists with schedule: the schedule
    And a position: "voter" exists with schedule: the schedule
    And an enrollment exists with position: position "voter", committee: the committee, votes: 1
    And a user: "sponsor" exists
    And a membership exists with period: the period, position: position "voter", user: user "sponsor"
    And a motion exists with committee: the committee, period: the period
    And a position: "chair" exists with schedule: the schedule
    And an enrollment exists with position: position: "chair", committee: the committee, manager: true
    And a user: "chair" exists
    And a membership exists with period: the period, position: position "chair", user: user "chair"
    And a sponsorship exists with motion: the motion, user: user "sponsor"

  Scenario: Propose the motion
    Given the motion is proposed
    Then I should see "Motion was successfully proposed."
    And the motion should exist with status: "proposed", published: true

  Scenario: Reject the motion
    Given the motion is rejected
    Then I should see "Motion was successfully rejected."
    And the motion should exist with status: "rejected", published: true

  Scenario: Withdraw the motion
    Given the motion is withdrawn
    Then I should see "Motion was successfully withdrawn."
    And the motion should exist with status: "withdrawn", published: true

  Scenario: Restart the motion
    Given the motion is withdrawn
    And I am on the motions page for user: "sponsor"
    And I follow "Restart" within "#motions"
    Then I should see "Motion was successfully restarted."
    And the motion should exist with status: "started", published: true

  Scenario: Divide the motion
    Given the motion is divided
    Then I should see "Motion was successfully divided."
    And the motion should exist with status: "divided", published: true

