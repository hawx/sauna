Feature: Create sauna
  As forum software this is probably quite important
  I want to be able to make a new sauna
  So that peoples can post and sign-up and everything
  
  Scenario: Plain Sauna
    Given I want a "Sauna" called "Test Sauna"
    And I want an admin called "John Doe" with password "password"
    When the Sauna is created
    Then the Sauna should be called "Test Sauna"
    And the admin should be called "John Doe"
    
  Scenario: Login
    Given a Sauna already exists
    And I want to log in as "johndoe" with a password "password"
    When I log in
    Then log out
    
  Scenario: Create Discussion
    Given a Sauna already exists
    And I am logged in as "johndoe" with a password "password"
    And I want to create a discussion called "Test Discussion"
    When I create the discussion
    Then it's name should be "Test Discussion"
    
  Scenario: Create Post
    Given a Discussion "Test Discussion" already exists
    And I am logged in as "johndoe" with a password "password"
    And I want to create a post called "Test Post" with content "Hey a post that looks __AWESOME__"
    When I create the post
    Then it's name should be "Test Post"