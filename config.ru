require 'appengine-rack'

require 'guestbook'


AppEngine::Rack.configure_app(
    :application => "jrubylicious",
    :version => 2)
run Sinatra::Application
