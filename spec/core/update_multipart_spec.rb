require 'spec_helper'
require 'rack/test'
require 'rack/lint'
require 'tdiary/application'

# Locks the multipart form-data POST behaviour of the Rack update path,
# which is used by file upload plugins (e.g. image.rb).
describe 'multipart POST to the update dispatcher' do
	include Rack::Test::Methods

	def app
		@app ||= Rack::Builder.new do
			map '/' do
				use Rack::Lint
				run TDiary::Dispatcher.index
			end

			map '/update.rb' do
				use Rack::Lint
				run TDiary::Dispatcher.update
			end
		end
	end

	let(:work_conf) { File.expand_path('../../../tdiary.conf', __FILE__) }
	let(:work_data_dir) { File.expand_path('../../../tmp/data', __FILE__) }

	before do
		FileUtils.cp_r File.expand_path('../../fixtures/tdiary.conf.rack', __FILE__), work_conf
		FileUtils.mkdir_p work_data_dir
		FileUtils.cp_r File.expand_path('../../fixtures/just_installed.conf', __FILE__), File.join(work_data_dir, 'tdiary.conf')
	end

	after do
		FileUtils.rm_rf work_data_dir
		FileUtils.rm_f work_conf
	end

	it '日記の本文が multipart POST で差し替わる' do
		referer = 'http://example.org/update.rb'

		post '/update.rb', {
			'year' => '2026', 'month' => '4', 'day' => '15',
			'title' => 'multipart test', 'body' => 'first version', 'append' => '追記'
		}, 'HTTP_REFERER' => referer
		expect(last_response.status).to eq 200

		post '/update.rb', {
			'year' => '2026', 'month' => '4', 'day' => '15', 'old' => '20260415',
			'title' => 'multipart test', 'body' => 'replaced version', 'replace' => '上書き',
			'date' => Rack::Test::UploadedFile.new(StringIO.new('20260415'), 'text/plain', original_filename: 'date.txt')
		}, 'HTTP_REFERER' => referer
		expect(last_response.status).to eq 200

		get '/?date=20260415'
		expect(last_response.status).to eq 200
		expect(last_response.body).to include 'replaced version'
		expect(last_response.body).not_to include 'first version'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
