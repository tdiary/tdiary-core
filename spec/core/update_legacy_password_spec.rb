require 'spec_helper'
require 'rack/test'
require 'tmpdir'
require 'tdiary/application'

describe 'update form behind the Basic authentication' do
	include Rack::Test::Methods

	around do |example|
		Dir.mktmpdir do |dir|
			@htpasswd = File.join(dir, '.htpasswd')
			example.run
		end
	end

	def app
		htpasswd = @htpasswd
		Rack::Builder.new do
			map '/update.rb' do
				use TDiary::Rack::Auth::Basic, htpasswd
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

	it 'asks to recreate a crypt password' do
		File.write(@htpasswd, "alice:EY.0WvbqI6dx2\n")
		basic_authorize 'alice', 'secret passphrase'
		get '/update.rb'
		expect(last_response).to be_ok
		expect(last_response.body).to include 'CRYPT方式'
	end

	it 'says nothing for a bcrypt password' do
		File.write(@htpasswd, "alice:$2y$05$gDJJdu6rLpNcPJCwlLRrKO8XBRlvFCIKBQvmWQA97L7xWZeVDWb12\n")
		basic_authorize 'alice', 'secret passphrase'
		get '/update.rb'
		expect(last_response).to be_ok
		expect(last_response.body).not_to include 'CRYPT方式'
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
