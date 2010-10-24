require File.dirname(__FILE__) + "/../spec_helper"

require 'capybara/dsl'
require 'rack'

require File.dirname(__FILE__) + '/../../tdiary/tdiary_application'

Capybara.app = Rack::Builder.new do
	map '/' do
		run TDiary::Application.new(:index)
	end

	map '/index.rb' do
		run TDiary::Application.new(:index)
	end

	map '/update.rb' do
		run TDiary::Application.new(:update)
	end
end

RSpec.configure do |config|
  config.include Capybara
end

Capybara.save_and_open_page_path = File.dirname(__FILE__) + '../../tmp'

# Put your acceptance spec helpers inside /spec/acceptance/support
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
