require 'sinatra/base'

# standard gems
require 'time'
require 'yaml'

# other gems
require 'sass'
require 'rdiscount'

#require 'pony'

require 'sqlite3'
require 'dm-core'
require 'dm-timestamps'
require 'digest/sha1'

# get rest of sauna

require 'lib/auth'
require 'lib/helpers'

require 'lib/sauna'
require 'lib/member' # <= lazy symbol issue is caused by this

require 'lib/discussion'
require 'lib/post'
require 'lib/comment'

require 'lib/topic'
require 'lib/tag'


class Sauna < Sinatra::Base

  include Models
  use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
  
  set :root,   File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public") }
  set :views,  Proc.new { File.join(root, "views") }
  
  configure :development do 
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/forum.db")
    DataMapper.auto_upgrade!
  end
  
  
  get '/' do
    if Sauna.first.nil?
      @sauna = Sauna.new
      @sauna.name = "Setup"
      @title = "Setup"
      erb :setup, :layout => :form
    else
      @sauna = Sauna.first
      @title = @sauna.name
      erb :index
    end
  end
  
  post '/setup' do
    @sauna = Sauna.new
    @sauna.attributes = params[:sauna]
    @sauna.save
    
    puts "New Sauna created..."
    p Sauna.first
  
    @sauna = Sauna.first
    @member = @sauna.members.new
    @member.attributes = params[:member]
    @member.access_level = 3
                         
    @member.save
    p @member
    puts "Admin created..."
    
    redirect '/'
  end
  
  get '/login' do
    @sauna = Sauna.first
    @title = "Login"
    erb :login, :layout => :form
  end
  
  post '/login' do
    if user = Member.authenticate(params[:username], params[:password])
      session[:user] = user.id
      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        session[:notice] = "Logged in as #{user.username}"
        redirect '/'
      end
    else
      session[:notice] = "Log in falied"
      redirect '/login'
    end
  end
  
  get '/logout' do
    session[:user] = nil
    session[:notice] = "Logged out"
    redirect '/'
  end
  
end
=begin
load 'routes/discussion.rb'
load 'routes/post.rb'
load 'routes/member.rb'
load 'routes/tag.rb'
=end