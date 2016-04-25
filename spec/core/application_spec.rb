require 'spec_helper'
require 'rack/test'
require 'tdiary/application'

describe TDiary::Application do
	include Rack::Test::Methods

	before do
	end

	describe '#call' do
		let(:app) { TDiary::Application.new }

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

			let(:app) { TDiary::Application.new }

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
					lambda {|env| raise StandardError.new }
				)
			end

			it do
				get '/'
				expect(last_response.status).to eq 500
				expect(last_response.body).to match(/^StandardError/)
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
