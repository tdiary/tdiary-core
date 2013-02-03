require 'spec_helper'
require 'rack/test'
require 'tdiary/rack/html_anchor'

describe TDiary::Rack::HtmlAnchor do
	include Rack::Test::Methods

	describe "html anchor" do
		let(:app) { TDiary::Rack::HtmlAnchor.new(
			lambda{|env| [200, {}, ['Awesome']]} )}

		it 'should not do anything for root access' do
			get '/'
			last_request.params['date'].should == nil
			last_request.query_string.should == ''
		end

		it 'should remove the file name from PATH_INFO' do
			get '/20120501.html'
			last_request.env['PATH_INFO'].should == '/'
			get '/diary/20120501.html'
			last_request.env['PATH_INFO'].should == '/diary/'
		end

		it 'should add date query' do
			get '/diary/0501.html'
			last_request.params['date'].should == "0501"
			get '/0501.html'
			last_request.params['date'].should == "0501"
			get '/201205.html'
			last_request.params['date'].should == "201205"
			get '/20120501.html'
			last_request.params['date'].should == "20120501"
		end

		it 'should add date query when using section_permalink_anchor plugin' do
			get '/20120501p01.html'
			last_request.params['date'].should == "20120501"
			last_request.params['p'].should == "01"
		end

		it 'should replace date query' do
			get '/20120501.html?date=20120101'
			last_request.params['date'].should == "20120501"
		end

		it 'should not break original query' do
			get '/?date=20120501'
			last_request.params['date'].should == "20120501"
			get '/index.rb?date=20120501'
			last_request.params['date'].should == "20120501"
			get '/index.rb?date=20120501&p=01'
			last_request.params['date'].should == "20120501"
			last_request.params['p'].should == "01"
		end
	end
end
