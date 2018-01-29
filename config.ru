$:.unshift( File.join(File::expand_path(File::dirname( __FILE__ )), 'lib' ) )
require 'tdiary/application'

use ::Rack::Reloader unless ENV['RACK_ENV'] == 'production'
run TDiary::Application.new
