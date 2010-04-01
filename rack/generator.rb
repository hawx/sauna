require 'sinatra/base'

require 'sass'
require 'coffee-script'

module Rack
  class SASS < Sinatra::Base
    set :views, 'views/'
  
    get '/css/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass ("sass/" + params[:name]).to_sym
    end
  end
  
  class Coffee < Sinatra::Base
    set :root, 'coffee/'
  
    get '/js/:name.js' do
      content_type 'text/javascript', :charset => 'utf-8'
      file = "templates/coffee/#{params[:name]}.coffee"
      coffee = File.join( Dir.pwd, file )
      CoffeeScript.compile( File.read(coffee) )
    end
  end
end