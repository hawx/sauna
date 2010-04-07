require 'sauna' 
require 'rack/generator'

use Rack::SASS
run Sauna::App