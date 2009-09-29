Feature: Manage terms
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new term
    Given I am on the new term page
    When I fill in "Schedule" with "schedule 1"
    And I fill in "Starts at" with "starts_at 1"
    And I fill in "Ends at" with "ends_at 1"
    And I press "Create"
    Then I should see "schedule 1"
    And I should see "starts_at 1"
    And I should see "ends_at 1"

  Scenario: Delete term
    Given the following terms:
      |schedule|starts_at|ends_at|
      |schedule 1|starts_at 1|ends_at 1|
      |schedule 2|starts_at 2|ends_at 2|
      |schedule 3|starts_at 3|ends_at 3|
      |schedule 4|starts_at 4|ends_at 4|
    When I delete the 3rd term
    Then I should see the following terms:
      |Schedule|Starts at|Ends at|
      |schedule 1|starts_at 1|ends_at 1|
      |schedule 2|starts_at 2|ends_at 2|
      |schedule 4|starts_at 4|ends_at 4|
