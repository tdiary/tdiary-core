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
			expect(last_response).to be_ok
		end

		it 'should return 200 for a nyear' do
			get '/0501.html'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a month' do
			get '/201205.html'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a day' do
			get '/20120501.html'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a day with section_permalink_anchor plugin' do
			get '/20120501p01.html'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a day with query' do
			get '/?date=20120501'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a day with query and section_permalink_anchor plugin' do
			get '/?date=20120501&p=01'
			expect(last_response).to be_ok
		end

		it 'should return 200 for a day with index.rb and query' do
			get '/index.rb?date=20120501'
			expect(last_response).to be_ok
		end

		it 'should return 404 for access to the invalid file' do
			get '/20120501'
			expect(last_response.status).to be 404
			get '/invalid'
			expect(last_response.status).to be 404
			head '/invalid'
			expect(last_response.status).to be 404
			expect(last_response.body.length).to be 0
		end

		it 'should return 404 for access to the invalid directory' do
			get '/invalid/'
			expect(last_response.status).to eq(404)
		end
	end
end
