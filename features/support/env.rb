require File.join(File.dirname(__FILE__), *%w[.. .. sauna.rb])
require 'capybara/cucumber'
require 'sinatra/base'

#configure do
#  set :environment, :test
#  set :root, File.dirname(__FILE__)
#end



Capybara.app = Sauna::App
