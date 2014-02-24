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
			expect(last_request.params['date']).to eq(nil)
			expect(last_request.query_string).to eq('')
		end

		it 'should remove the file name from PATH_INFO' do
			get '/20120501.html'
			expect(last_request.env['PATH_INFO']).to eq('/')
			get '/diary/20120501.html'
			expect(last_request.env['PATH_INFO']).to eq('/diary/')
		end

		it 'should add date query' do
			get '/diary/0501.html'
			expect(last_request.params['date']).to eq("0501")
			get '/0501.html'
			expect(last_request.params['date']).to eq("0501")
			get '/201205.html'
			expect(last_request.params['date']).to eq("201205")
			get '/20120501.html'
			expect(last_request.params['date']).to eq("20120501")
		end

		it 'should add date query when using section_permalink_anchor plugin' do
			get '/20120501p01.html'
			expect(last_request.params['date']).to eq("20120501")
			expect(last_request.params['p']).to eq("01")
		end

		it 'should replace date query' do
			get '/20120501.html?date=20120101'
			expect(last_request.params['date']).to eq("20120501")
		end

		it 'should not break original query' do
			get '/?date=20120501'
			expect(last_request.params['date']).to eq("20120501")
			get '/index.rb?date=20120501'
			expect(last_request.params['date']).to eq("20120501")
			get '/index.rb?date=20120501&p=01'
			expect(last_request.params['date']).to eq("20120501")
			expect(last_request.params['p']).to eq("01")
		end
	end
end
