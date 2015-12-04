$:.unshift( File.join(File::expand_path(File::dirname( __FILE__ )), 'lib' ).untaint )
require 'tdiary/application'

use ::Rack::Reloader unless ENV['RACK_ENV'] == 'production'
run TDiary::Application.new
