require 'spec_helper'
require 'rack/test'
require 'tdiary/application'

describe TDiary::Dispatcher do
	include Rack::Test::Methods

	let(:app) do
		Rack::Builder.new do
			run TDiary::Dispatcher.index
		end
	end

	let(:fixture_conf) { File.expand_path('../../fixtures/just_installed.conf', __FILE__) }
	let(:work_data_dir) { File.expand_path('../../../tmp/data', __FILE__) }
	let(:tdiary_conf) { File.expand_path('../../fixtures/tdiary.conf.rack', __FILE__) }
	let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }

	before do
		FileUtils.cp_r tdiary_conf, work_conf, verbose: false
		FileUtils.mkdir_p work_data_dir
		FileUtils.cp_r fixture_conf, File.join(work_data_dir, 'tdiary.conf'), verbose: false
	end

	after do
		FileUtils.rm_f work_conf
		FileUtils.rm_rf work_data_dir
	end

	describe 'conditional GET' do
		it 'returns 304 when If-None-Match matches the etag' do
			get '/'
			expect(last_response.status).to eq 200
			etag = last_response.headers['etag']
			expect(etag).not_to be_nil

			get '/', {}, { 'HTTP_IF_NONE_MATCH' => etag }
			expect(last_response.status).to eq 304
		end

		it 'returns 200 without If-None-Match' do
			get '/'
			expect(last_response.status).to eq 200

			get '/'
			expect(last_response.status).to eq 200
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
