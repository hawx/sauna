# this needs to be at the top or it won't go to test mode
ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), *%w[.. .. sauna.rb])
require 'capybara/cucumber'
require 'sinatra'

Capybara.app = Sauna::App

at_exit do
  # remove the db now tests are finished
  File.delete "test.db"
end