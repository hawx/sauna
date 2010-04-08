require 'sinatra/base'

require 'sass'

module Rack
  class SASS < Sinatra::Base
    set :views, "views/sass/"
  
    get '/css/:name.css' do
      content_type 'text/css', :charset => 'utf-8'
      sass params[:name].to_sym
    end
  end
end