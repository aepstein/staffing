Feature: Manage memberships
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new membership
    Given I am on the new membership page
    When I fill in "User" with "user 1"
    And I fill in "Term" with "term 1"
    And I fill in "Position" with "position 1"
    And I fill in "Request" with "request 1"
    And I fill in "Starts at" with "starts_at 1"
    And I fill in "Ends at" with "ends_at 1"
    And I press "Create"
    Then I should see "user 1"
    And I should see "term 1"
    And I should see "position 1"
    And I should see "request 1"
    And I should see "starts_at 1"
    And I should see "ends_at 1"

  Scenario: Delete membership
    Given the following memberships:
      |user|term|position|request|starts_at|ends_at|
      |user 1|term 1|position 1|request 1|starts_at 1|ends_at 1|
      |user 2|term 2|position 2|request 2|starts_at 2|ends_at 2|
      |user 3|term 3|position 3|request 3|starts_at 3|ends_at 3|
      |user 4|term 4|position 4|request 4|starts_at 4|ends_at 4|
    When I delete the 3rd membership
    Then I should see the following memberships:
      |User|Term|Position|Request|Starts at|Ends at|
      |user 1|term 1|position 1|request 1|starts_at 1|ends_at 1|
      |user 2|term 2|position 2|request 2|starts_at 2|ends_at 2|
      |user 4|term 4|position 4|request 4|starts_at 4|ends_at 4|
