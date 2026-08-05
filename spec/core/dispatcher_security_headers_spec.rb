require 'spec_helper'
require 'rack/test'
require 'rack/lint'
require 'tdiary/application'

# Locks the security headers injected by TDiary::Dispatcher, which is
# shared by all the hosting paths (Rack, CGI and FCGI).
describe 'security headers of the dispatcher' do
	include Rack::Test::Methods

	def app
		@app ||= Rack::Builder.new do
			map '/update.rb' do
				use Rack::Lint
				run TDiary::Dispatcher.update
			end

			map '/' do
				use Rack::Lint
				run TDiary::Dispatcher.index
			end
		end
	end

	let(:fixture_conf) { File.expand_path('../../fixtures/just_installed.conf', __FILE__) }
	let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }
	let(:work_data_dir) { File.expand_path('../../../tmp/data', __FILE__) }

	def write_data_conf( extra = '' )
		File.write File.join(work_data_dir, 'tdiary.conf'), File.read(fixture_conf) + "\n" + extra
	end

	before do
		FileUtils.cp_r File.expand_path('../../fixtures/tdiary.conf.rack', __FILE__), work_conf
		FileUtils.mkdir_p work_data_dir
		write_data_conf
	end

	after do
		FileUtils.rm_rf work_data_dir
		FileUtils.rm_f work_conf
	end

	describe 'X-Content-Type-Options' do
		it 'is nosniff on the index response' do
			get '/'
			expect(last_response.status).to eq 200
			expect(last_response.headers['x-content-type-options']).to eq 'nosniff'
		end

		it 'is nosniff on the update response' do
			get '/update.rb'
			expect(last_response.status).to eq 200
			expect(last_response.headers['x-content-type-options']).to eq 'nosniff'
		end

		it 'is nosniff on a 304 response' do
			get '/'
			etag = last_response.headers['etag']
			get '/', {}, { 'HTTP_IF_NONE_MATCH' => etag }
			expect(last_response.status).to eq 304
			expect(last_response.headers['x-content-type-options']).to eq 'nosniff'
		end
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
