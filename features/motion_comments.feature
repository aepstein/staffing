Feature: Manage motion comments
  In order to facilitate public comment on select motions
  As a user
  I want to create, edit, see, destroy comments

Scenario Outline: Access control existing comment
  Given a current published, proposed motion exists of sponsored origin to which I have a <relationship> relationship
  And a comment for the motion exists to which I have a <relationship> relationship
  And the motion is <open> open for comment
  Then I <show> see the motion comment
  And I <create> create comments for the motion
  And I <update> update the motion comment
  And I <destroy> destroy the motion comment
  Examples:
  |relationship|open     |show|create |update |destroy|
  |admin       |never    |may |may    |may    |may    |
  |staff       |never    |may |may    |may    |may not|
  |commenter   |never    |may |may not|may not|may not|
  |commenter   |no longer|may |may not|may not|may not|
  |commenter   |still    |may |may    |may    |may not|
  |plain       |still    |may |may    |may not|may not|

@javascript
Scenario: Create/edit a motion comment
  When I create a motion comment
  Then I should see the new motion comment
  When I update the motion comment
  Then I should see the edited motion comment

Scenario Outline: Reports for meeting
  Given a current published, proposed motion exists of sponsored origin to which I have a <relationship> relationship
  And the motion <has> comments
  When I download the comments pdf report for the motion
  Then I should <see> the comments report
  Examples:
    |relationship | has    | see     |
    |staff        | has    | see     |
    |staff        | has no | not see |

