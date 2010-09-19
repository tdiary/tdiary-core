require 'rubygems'
require 'bundler'

Bundler.setup
Bundler.require :default, :test

require 'steak'
require 'capybara/dsl'
require 'rack'

require File.dirname(__FILE__) + '/../../tdiary_app'

Capybara.app = Rack::Builder.new do
	map '/' do
		run Rack::TDiaryApp.new(:index)
	end

	map '/index.rb' do
		run Rack::TDiaryApp.new(:index)
	end

	map '/update.rb' do
		run Rack::TDiaryApp.new(:update)
	end
end

RSpec.configure do |config|
  config.include Capybara
end

Capybara.default_selector = :css

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
