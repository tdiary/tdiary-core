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

	describe 'frame embedding control' do
		it 'restricts the update response to same-origin framing' do
			get '/update.rb'
			expect(last_response.headers['content-security-policy']).to eq "frame-ancestors 'self'"
			expect(last_response.headers['x-frame-options']).to eq 'SAMEORIGIN'
		end

		it 'leaves the index response unrestricted by default' do
			get '/'
			expect(last_response.headers['content-security-policy']).to be_nil
			expect(last_response.headers['x-frame-options']).to be_nil
		end

		it 'maps x_frame_options SAMEORIGIN to frame-ancestors self on the index response' do
			write_data_conf "x_frame_options = 'SAMEORIGIN'"
			get '/'
			expect(last_response.headers['content-security-policy']).to eq "frame-ancestors 'self'"
			expect(last_response.headers['x-frame-options']).to eq 'SAMEORIGIN'
		end

		it 'maps x_frame_options DENY to frame-ancestors none on the index response' do
			write_data_conf "x_frame_options = 'DENY'"
			get '/'
			expect(last_response.headers['content-security-policy']).to eq "frame-ancestors 'none'"
			expect(last_response.headers['x-frame-options']).to eq 'DENY'
		end

		it 'passes an unmappable x_frame_options value through without CSP' do
			write_data_conf "x_frame_options = 'ALLOW-FROM https://example.net/'"
			get '/'
			expect(last_response.headers['content-security-policy']).to be_nil
			expect(last_response.headers['x-frame-options']).to eq 'ALLOW-FROM https://example.net/'
		end
	end

	describe 'Referrer-Policy' do
		it 'defaults to strict-origin-when-cross-origin' do
			get '/'
			expect(last_response.headers['referrer-policy']).to eq 'strict-origin-when-cross-origin'
		end

		it 'follows conf.referrer_policy' do
			write_data_conf "referrer_policy = 'no-referrer'"
			get '/'
			expect(last_response.headers['referrer-policy']).to eq 'no-referrer'
		end
	end

	describe 'Strict-Transport-Security' do
		it 'is absent by default even on HTTPS' do
			get 'https://www.example.org/'
			expect(last_response.headers['strict-transport-security']).to be_nil
		end

		it 'is sent on HTTPS when conf.hsts is set' do
			write_data_conf "hsts = 'max-age=63072000; includeSubDomains'"
			get 'https://www.example.org/'
			expect(last_response.headers['strict-transport-security']).to eq 'max-age=63072000; includeSubDomains'
		end

		it 'maps conf.hsts = true to a one year max-age' do
			write_data_conf "hsts = true"
			get 'https://www.example.org/'
			expect(last_response.headers['strict-transport-security']).to eq 'max-age=31536000'
		end

		it 'is not sent on plain HTTP even when conf.hsts is set' do
			write_data_conf "hsts = true"
			get '/'
			expect(last_response.headers['strict-transport-security']).to be_nil
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
