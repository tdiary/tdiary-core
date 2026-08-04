require 'spec_helper'
require 'rack/test'
require 'stringio'
require 'tdiary/rack/error_handler'

describe TDiary::Rack::ErrorHandler do
	include Rack::Test::Methods

	describe 'when the app succeeds' do
		let(:app) { TDiary::Rack::ErrorHandler.new(
			lambda{|env| [200, {'content-type' => 'text/plain'}, ['Awesome']]} )}

		it 'passes the response through' do
			get '/'
			expect(last_response.status).to eq 200
			expect(last_response.body).to eq 'Awesome'
		end
	end

	describe 'when the app raises' do
		let(:app) { TDiary::Rack::ErrorHandler.new(
			lambda{|env| raise StandardError, 'boom'} )}
		let(:errors) { StringIO.new }

		it 'returns a plain 500 without the exception details' do
			get '/', {}, 'rack.errors' => errors
			expect(last_response.status).to eq 500
			expect(last_response.headers['content-type']).to eq 'text/plain'
			expect(last_response.body).to eq "500 Internal Server Error\n"
		end

		it 'reports the class, message and backtrace to rack.errors' do
			get '/', {}, 'rack.errors' => errors
			expect(errors.string).to match(/^StandardError: boom$/)
			expect(errors.string).to include __FILE__
		end
	end

	describe 'when the app raises a non-StandardError exception' do
		let(:app) { TDiary::Rack::ErrorHandler.new(
			lambda{|env| raise Exception, 'fatal'} )}
		let(:errors) { StringIO.new }

		it 'catches it too' do
			get '/', {}, 'rack.errors' => errors
			expect(last_response.status).to eq 500
			expect(errors.string).to match(/^Exception: fatal$/)
		end
	end
end
