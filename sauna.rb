require 'sinatra/base'

# standard gems
require 'time'
require 'yaml'
require 'digest/sha1'

# other gems
require 'sass'
require 'rdiscount'

if RUBY_VERSION >= "1.9"
  require 'mail'
else
  require 'pony'
end

require 'sqlite3'
require 'dm-core'
require 'dm-timestamps'

# get rest of sauna

require 'lib/auth'
require 'lib/helpers'

require 'lib/sauna'
require 'lib/member'

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
    
    session[:notice] = "You have created a new Sauna!"
    redirect '/'
  end
  
  get '/login' do
    @sauna = Sauna.first
    @title = "Login"
    erb :login, :layout => :form
  end
  
  post '/login' do
    #if Member.first(:username => params[:username]).logged_in
    #  session[:notice] = "You are already logged in, log out and try again"
    #  if session[:return_to]
    #    redirect_url = session[:return_to]
    #    session[:return_to] = false
    #    redirect redirect_url
    #  else
    #    redirect '/'
    #  end
    #end
    
    if user = Member.authenticate(params[:username], params[:password])
      session[:user] = user.id
      session[:notice] = "Logged in as #{user.username}"
      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        redirect '/'
      end
    else
      session[:notice] = "Log in failed"
      redirect '/login'
    end
  end
  
  get '/logout' do
    current_user.logged_in = false
    current_user.save
    
    session[:user] = nil
    session[:notice] = "Logged out"
    redirect '/'
  end
  
  before do
    # this stops the same message from coming up twice or more
    if session[:notice] == session[:oldnotice]
      session[:notice] = ""
    end
    session[:oldnotice] = session[:notice]
  end
  
end

load 'routes/discussion.rb'
load 'routes/post.rb'
load 'routes/member.rb'
load 'routes/tag.rb'