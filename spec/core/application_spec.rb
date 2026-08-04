require 'spec_helper'
require 'rack/test'
require 'rack/lint'
require 'tdiary/application'

describe TDiary::Application do
	include Rack::Test::Methods

	before do
	end

	describe '#call' do
		let(:app) { Rack::Lint.new(TDiary::Application.new) }

		context "when is accessed to index"
		it do
			get '/'
			expect(last_response.status).to eq 200
		end

		context "when is accessed to update" do
			it do
				get '/update.rb'
				expect(last_response.status).to eq 401
			end
		end

		context "with base_dir" do
			before do
				TDiary.configuration.options['base_url'] = 'http://example.com/diary/'
			end

			after do
				TDiary.configuration.options['base_url'] = ''
			end

			let(:app) { Rack::Lint.new(TDiary::Application.new) }

			it do
				get '/diary/'
				expect(last_response.status).to eq 200
			end

			context "when access to root directory" do
				it do
					get '/'
					expect(last_response.status).to eq 404
				end
			end
		end

		context "when the application raises exception" do
			before do
				allow(TDiary::Dispatcher).to receive_message_chain(:index).and_return(
					lambda {|env| raise StandardError.new('boom') }
				)
			end

			let(:errors) { StringIO.new }

			it 'returns a plain 500 and reports the exception to rack.errors' do
				get '/', {}, 'rack.errors' => errors
				expect(last_response.status).to eq 500
				expect(last_response.body).not_to include 'StandardError'
				expect(errors.string).to match(/^StandardError: boom$/)
			end
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
