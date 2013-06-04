require 'spec_helper'
require 'rack/test'
require 'tdiary/rack/static'

describe TDiary::Rack::Static do
	include Rack::Test::Methods

	describe "reserve static files" do
		let(:app) { TDiary::Rack::Static.new(
			lambda{|env| [500, {}, ['Internal Server Error']]}, 'doc')}

		it 'should return the file in static directory' do
			get '/README.md'
			last_response.should be_ok
		end

		it 'should run the app if file is not exist' do
			get '/index.rb'
			last_response.status.should be 500
		end
	end
end
