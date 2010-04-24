require 'sinatra/base'

# standard gems
require 'time'
require 'yaml'
require 'digest/sha1'

# other gems
require 'rdiscount'
require 'sass'

require 'mail' if RUBY_VERSION >= "1.9"
require 'aws/s3'

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

module Sauna
  class App < Sinatra::Base
  
    include Models
    use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
    
    configure do 
      set :root,   File.dirname(__FILE__)
      set :public, Proc.new { File.join(root, "public") }
      set :views,  Proc.new { File.join(root, "views") }
      enable :static
    end
    
    configure :development do 
      DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/forum.db")
      DataMapper.auto_upgrade!
    end
    
    configure :production do
      DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://forum.db')
      DataMapper.auto_upgrade!
    end
    
    configure :test do
      DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/test.db")
      DataMapper.auto_upgrade!
    end
    
    
    get '/' do 
      if Sauna.first.nil?
        @sauna = Sauna.new
        @sauna.name = "Setup"
        @title = "Setup"
        template :setup, :form
      else
        @sauna = Sauna.first
        @title = @sauna.name
        template :index
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
    
    get '/settings/?' do
      login_required
      redirect '/' unless current_user.site_admin?
    
      @sauna = Sauna.first
      template :settings, :form
    end
    
    post '/settings/?' do
      @sauna = Sauna.first
      if params[:sauna][:s3] == "on"
        params[:sauna]['s3'] = true
      else
        params[:sauna]['s3'] = false
      end
      @sauna.attributes = params[:sauna]
      @sauna.save
      redirect '/'
    end
    
    get '/login' do
      @sauna = Sauna.first
      @title = "Login"
      template :login, :form
    end
    
    post '/login' do     
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
    
    get '/css/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass ("sass/" + params[:name]).to_sym
    end
    
    helpers do
      def template(template, layout = false)
        parts = template.to_s.split("_")
        path = parts.join("/").to_sym
        if layout == :form
          erb path, :layout => :form
        else
          erb path
        end
      end
    end
       
    before do
      if session[:notice] == session[:oldnotice]
        session[:notice] = ""
      end
      session[:oldnotice] = session[:notice]
    end
    
  end
end
load 'routes/discussion.rb'
load 'routes/post.rb'
load 'routes/member.rb'
load 'routes/tag.rb'