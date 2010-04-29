require 'appengine-rack'
AppEngine::Rack.configure_app(
  :application => 'mumbo-jumbo',
  :version => 4)
require 'mumbo'
run Sinatra::Application
