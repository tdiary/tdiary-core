require 'spec_helper'
require 'rack/test'
require 'tdiary/rack/valid_request_path'

describe TDiary::Rack::ValidRequestPath do
	include Rack::Test::Methods

	describe "valid request" do
		let(:app) { TDiary::Rack::ValidRequestPath.new(
			lambda{|env| [200, {}, ['Awesome']]} )}

		it 'should return 200 for valid path' do
			get '/'
			last_response.should be_ok
			get '/0501.html'
			last_response.should be_ok
			get '/201205.html'
			last_response.should be_ok
			get '/20120501.html'
			last_response.should be_ok
		end

		it 'should return 404 for invalid path' do
			get '/20120501'
			last_response.status.should be 404
			get '/invalid'
			last_response.status.should be 404
		end
	end
end
