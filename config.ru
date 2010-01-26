require 'appengine-rack'
require 'guestbook'
AppEngine::Rack.configure_app(
    :application => "mumbo-jumbo",
    :version => 4)
run Sinatra::Application
