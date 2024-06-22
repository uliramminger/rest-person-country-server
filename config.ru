# This file is used by Rack-based servers to start the application.

require_relative 'main'

require 'rack'
require 'rack/contrib'

use Rack::JSONBodyParser

run Sinatra::Application
