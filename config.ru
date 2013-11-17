$:.unshift( File::dirname( __FILE__ ).untaint )
require 'tdiary'
require 'tdiary/environment'
require 'tdiary/application'

use ::Rack::Reloader unless ENV['RACK_ENV'] == 'production'
base_dir = '/'
run TDiary::Application.new( base_dir )
