require 'digest/sha1'
require 'dm-core'
require 'dm-timestamps'
require 'dm-validations'

require 'sinatra/base'
require 'user'

=begin
  
  Turns out I was able to write a simple authentication extension....
  but the catch is it isn’t really an extension, I ended up just including
  the methods in a module which also holds all of the DM models. Then I call
  'include Models' and POW, it works.

=end

class App < Sinatra::Base
  include Models
  
  use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
  
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/forum.db")
  DataMapper.auto_upgrade!
  
  get '/' do
    current_user.username
  end
  
  get '/test' do
    login_required
    "logged in"
    redirect '/'
  end
  
  get '/create_user' do
    if User.first.nil?
      @user = User.new
      @user.attributes = {:username => "hawx", :password => "password"}
      @user.save
      p User.all
    else
      p "user already exists"
    end
    redirect "/"
  end

  get '/logout' do
    session[:user] = nil
    redirect '/'
  end
  
  get '/login' do
    params[:username] = "hawx"
    params[:password] = "password"
    if user = User.authenticate(params[:username], params[:password])
      session[:user] = user.id
      if session[:return_to]
        redirect_url = session[:return_to]
        session[:return_to] = false
        redirect redirect_url
      else
        redirect '/'
      end
    else
      redirect '/login'
    end
  end
  
end