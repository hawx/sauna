Given /^I want a "([^\"]*)" called "([^\"]*)"$/ do |object, name|
  visit('/')
  fill_in('Forum Name', :with => name)
end

Given /^I want an admin called "([^\"]*)" with password "([^\"]*)"$/ do |name, password|
  fill_in('First name', :with => name)
  fill_in('Last name', :with => name)
  fill_in('Age', :with => 17)
  fill_in('john@doe.com', :with => 'john@doe.com')
  fill_in('Username', :with => name.split(" ").join.downcase)
  fill_in('Password', :with => password)
  fill_in('Password', :with => password)
  click_button('Setup!')
end

When /^the Sauna is created$/ do
  !Sauna::App::Sauna.first.nil?
end

Then /^the Sauna should be called "([^\"]*)"$/ do |name|
  Sauna::App::Sauna.first.name == name
end

Then /^the admin should be called "([^\"]*)"$/ do |name|
  admin = Sauna::App::Member.get(1)
  (admin.fname + admin.sname) == name
end

Given /^a Sauna already exists$/ do
  !Sauna::App::Sauna.first.nil?
end

Given /^a Discussion "([^\"]*)" already exists$/ do |name|
  @discussion = Sauna::App::Discussion.first(:name => name)
end

Given /^I want to log in as "([^\"]*)" with a password "([^\"]*)"$/ do |username, password|
  visit('/login')
  fill_in('Username', :with => username)
  fill_in('Password', :with => password)
end

When /^I log in$/ do
  click_button('Login')
end

Then /^log out$/ do
  visit('/logout')
end

Given /^I am logged in as "([^\"]*)" with a password "([^\"]*)"$/ do |username, password|
  visit('/login')
  fill_in('Username', :with => username)
  fill_in('Password', :with => password)
  click_button('Login')
end

Given /^I want to create a discussion called "([^\"]*)"$/ do |name|
  visit('/discussion/new')
  fill_in('name', :with => name)
end

When /^I create the discussion$/ do
  click_button('Create Discussion')
end

Then /^it's name should be "([^\"]*)"$/ do |name|
  Sauna::App::Discussion.first(:name => name) || Sauna::App::Post.first(:title => name) || Sauna::App::Sauna.first(:name => name)
end


Given /^I want to create a post called "([^\"]*)" with content "([^\"]*)"$/ do |name, content|
  visit("#{@discussion.url}/post/new")
  fill_in('Title', :with => name)
  fill_in('Content', :with => content)
end

When /^I create the post$/ do
  click_button('Create post')
end

