require 'spec_helper'
require 'rack/test'
require 'tdiary/rack/valid_request_path'

describe TDiary::Rack::ValidRequestPath do
	include Rack::Test::Methods

	describe "valid request" do
		let(:app) { TDiary::Rack::ValidRequestPath.new(
			lambda{|env| [200, {}, ['Awesome']]} )}

		it 'should return 200 for latest' do
			get '/'
			last_response.should be_ok
		end

		it 'should return 200 for a nyear' do
			get '/0501.html'
			last_response.should be_ok
		end

		it 'should return 200 for a month' do
			get '/201205.html'
			last_response.should be_ok
		end

		it 'should return 200 for a day' do
			get '/20120501.html'
			last_response.should be_ok
		end

		it 'should return 200 for a day with query' do
			get '/?date=20120501'
			last_response.should be_ok
		end

		it 'should return 200 for a day with index.rb and query' do
			get '/index.rb?date=20120501'
			last_response.should be_ok
		end

		it 'should return 404 for access to the invalid file' do
			get '/20120501'
			last_response.status.should be 404
			get '/invalid'
			last_response.status.should be 404
			head '/invalid'
			last_response.status.should be 404
			last_response.body.length.should be 0
		end

		it 'should return 404 for access to the invalid directory' do
			get '/invalid/'
			last_response.status.should == 404
		end
	end
end
