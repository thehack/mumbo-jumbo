require 'appengine-rack'
require 'guestbook'
AppEngine::Rack.configure_app(
    :application => "mumbo25",
    :version => 1)
run Sinatra::Application
