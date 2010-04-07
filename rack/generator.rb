require 'sinatra/base'

require 'sass'

module Rack
  class SASS < Sinatra::Base
    set :views, 'views/'
  
    get '/css/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass ("sass/" + params[:name]).to_sym
    end
  end
end